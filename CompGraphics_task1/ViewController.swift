//
//  ViewController.swift
//  comp_graph_lab4
//
//  Created by Александр Рассохин on 03.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clippingView = ClippingView(frame: view.bounds)
        view.addSubview(clippingView)
        
        clippingView.setNeedsDisplay()
    }
}

class ClippingView: UIView {
    
    
    let INSIDE = 0; // 0000
    let LEFT = 1;   // 0001
    let RIGHT = 2;  // 0010
    let BOTTOM = 4; // 0100
    let TOP = 8;    // 1000
    
    lazy var xmax: Float = xmin + 200
    lazy var ymax: Float = ymin + 100
    lazy var xmin: Float = Float(bounds.width / 4)
    lazy var ymin: Float = Float(bounds.height - ((bounds.height / 2.2) + 100))
    
    var line: Line?
    var viewsForLinePoints: (firstPointView: UIView, secondPointView: UIView)?
    
    let windowLayer = CAShapeLayer()
    let outsideLayer = CAShapeLayer()
    let rectLayer = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        
        guard let line = line else { return }
        var lineInWindowCoordinates = line
        
        let isInsideWindow = clipLine(
            x0: &lineInWindowCoordinates.x0,
            y0: &lineInWindowCoordinates.y0,
            x1: &lineInWindowCoordinates.x1,
            y1: &lineInWindowCoordinates.y1)
                
        let outsideWindowPath = UIBezierPath()
        outsideWindowPath.move(to: CGPoint(x: CGFloat(line.x0), y: bounds.height - CGFloat(line.y0)))
        outsideWindowPath.addLine(to: CGPoint(x: CGFloat(line.x1), y: bounds.height - CGFloat(line.y1)))
        outsideLayer.path = outsideWindowPath.cgPath
        
        if isInsideWindow {
            let indsideWindowPath = UIBezierPath()
            indsideWindowPath.move(to: CGPoint(x: CGFloat(lineInWindowCoordinates.x0), y: bounds.height - CGFloat(lineInWindowCoordinates.y0)))
            indsideWindowPath.addLine(to: CGPoint(x: CGFloat(lineInWindowCoordinates.x1), y: bounds.height - CGFloat(lineInWindowCoordinates.y1)))
            windowLayer.path = indsideWindowPath.cgPath
        } else {
            windowLayer.path = nil
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        rectLayer.fillColor = nil
        rectLayer.strokeColor = UIColor.gray.cgColor
        rectLayer.lineWidth = 3
        
        windowLayer.fillColor = nil
        windowLayer.strokeColor = UIColor.red.cgColor
        windowLayer.lineWidth = 4
        
        outsideLayer.fillColor = nil
        outsideLayer.strokeColor = UIColor.black.cgColor
        outsideLayer.lineWidth = 4
        
        layer.addSublayer(rectLayer)
        layer.addSublayer(outsideLayer)
        layer.addSublayer(windowLayer)
        
        let rect = UIBezierPath(rect: CGRect(x: bounds.width / 4, y: bounds.height / 2.2, width: 200, height: 100))
        rectLayer.path = rect.cgPath
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        if line != nil {
            return
        }
        
        let location = sender.location(in: self)
        
        let pointView = UIView()
        pointView.center = location
        pointView.frame.size.height = 5
        pointView.frame.size.width = 5
        pointView.backgroundColor = .black
        addSubview(pointView)
    
        if viewsForLinePoints?.firstPointView == nil {
            viewsForLinePoints = (pointView, UIView())
            return
        }
        
        guard let firstPointView = viewsForLinePoints?.firstPointView else {
            return
            
        }
        
        line = Line(x0: Float(firstPointView.center.x),
                          y0: Float(bounds.height - firstPointView.center.y),
                          x1: Float(pointView.center.x),
                          y1: Float(bounds.height - pointView.center.y))
        
        viewsForLinePoints?.secondPointView = pointView
        [pointView, firstPointView].forEach { view in
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized)))
            
        }
      
        setNeedsDisplay()
    }
    
    var dragStartPoint: CGPoint?
    @objc func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        guard let pointView = sender.view else {return}
        let tag = pointView.tag
        
        switch sender.state {
        case .began:
            dragStartPoint = pointView.center
            
        case .changed:
            let xTranslation = sender.translation(in: self).x
            let yTranslation = sender.translation(in: self).y

            pointView.center.x = dragStartPoint!.x + xTranslation
            pointView.center.y = dragStartPoint!.y + yTranslation
            
            guard let viewsForLinePoints = viewsForLinePoints else {return}
            
            let anotherPointView = viewsForLinePoints.firstPointView == pointView ? viewsForLinePoints.secondPointView : viewsForLinePoints.firstPointView
                    
            line = Line(
                x0: Float(anotherPointView.center.x),
                y0: Float(bounds.height - anotherPointView.center.y),
                x1: Float(pointView.center.x),
                y1: Float(bounds.height - pointView.center.y))
            
            setNeedsDisplay()
        case .ended:
            dragStartPoint = nil
            
        default: break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func getBitCodeForPointLocation(x: Float, y: Float) -> Int {
        var code = INSIDE;

        if (x < xmin) {          // слева от окна
            code |= LEFT;
        }
        else if (x > xmax) {     // справа от окна
            code |= RIGHT;
        }
        
        if (y < ymin) {          // снизу от окна
            code |= BOTTOM;
        }
        else if (y > ymax) {     // сверху от окна
            code |= TOP;
        }
        
        return code;
    }

    func clipLine(x0: inout Float, y0: inout Float, x1: inout Float, y1: inout Float) -> Bool {
        var outcode0 = getBitCodeForPointLocation(x: x0, y: y0)
        var outcode1 = getBitCodeForPointLocation(x: x1, y: y1)
        
        var accept = false;

        while (true) {
            if (((outcode0 | outcode1) == 0)) {
                accept = true;
                break;
            } else if ((outcode0 & outcode1) != 0) {
                break;
            } else {
                var x, y: Float;

                let outcodeOut: Int = outcode1 > outcode0 ? outcode1 : outcode0;
                
                if ((outcodeOut & TOP) != 0) {           // точка над окном
                    x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                    y = ymax;
                } else if ((outcodeOut & BOTTOM) != 0) { // точка под окном
                    x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                    y = ymin;
                } else if ((outcodeOut & RIGHT) != 0) {  // точка справа от окна
                    y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                    x = xmax;
                } else {   // точка слева от окна
                    y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                    x = xmin;
                }
                
                print("x: \(x) : y: \(y)")

                if (outcodeOut == outcode0) {
                    x0 = x;
                    y0 = y;
                    outcode0 = getBitCodeForPointLocation(x: x0, y: y0);
                } else {
                    x1 = x;
                    y1 = y;
                    outcode1 = getBitCodeForPointLocation(x: x1, y: y1);
                }
            }
        }
        return accept;
    }


}

struct Line {
    var x0: Float
    var y0: Float
    var x1: Float
    var y1: Float
}

