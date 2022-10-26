import UIKit

class ViewController: UIViewController {
    
    let bezierView = BezierView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(bezierView)
        bezierView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bezierView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bezierView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bezierView.topAnchor.constraint(equalTo: view.topAnchor),
            bezierView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
                
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureRecognized(sender:)))
        
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    var amountOfAddedPoints = 0
    @objc func gestureRecognized(sender: UITapGestureRecognizer) {
        guard amountOfAddedPoints < 4 else { return }
        
        let location = sender.location(in: view)
        
        let pointView = UIView()
        pointView.frame.size.width = 5
        pointView.frame.size.height = 5
        pointView.center = location
        pointView.tag = amountOfAddedPoints
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        pointView.addGestureRecognizer(panGestureRecognizer)
        
        pointView.backgroundColor = .black
        view.addSubview(pointView)
        
        switch amountOfAddedPoints {
        case 0:
            bezierView.point0 = location
        case 1:
            bezierView.point1 = location
        case 2:
            bezierView.point2 = location
        case 3:
            bezierView.point3 = location
        default:
            break
        }
        
        amountOfAddedPoints += 1
        
        if amountOfAddedPoints == 4 {
            bezierView.setNeedsDisplay()
        }
        
    }
    
    var dragStartPoint: CGPoint?
    @objc func panGestureRecognized(gesture: UIPanGestureRecognizer) {
        
        guard amountOfAddedPoints == 4,
              let pointView = gesture.view else {return}
        
        switch gesture.state {
        case .began:
            dragStartPoint = pointView.frame.origin
        case .changed:
            let xTranslation = gesture.translation(in: self.view).x
            let yTranslation = gesture.translation(in: self.view).y

            pointView.center.x = dragStartPoint!.x + xTranslation
            pointView.center.y = dragStartPoint!.y + yTranslation
            
            switch pointView.tag {
            case 0:
                bezierView.point0 = pointView.center
            case 1:
                bezierView.point1 = pointView.center
            case 2:
                bezierView.point2 = pointView.center
            case 3:
                bezierView.point3 = pointView.center
            default:
                break
            }
            
            bezierView.setNeedsDisplay()
        case.ended:
            dragStartPoint = nil
            
        default:
            break
        }
    }
    

}

class BezierView: UIView {
    var point0: CGPoint = CGPoint(x: 0, y: 0)
    var point1: CGPoint = CGPoint(x: 0, y: 0)
    var point2: CGPoint = CGPoint(x: 0, y: 0)
    var point3: CGPoint = CGPoint(x: 0, y: 0)
    
    private let bezierLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(bezierLayer)
        bezierLayer.fillColor = nil
        bezierLayer.strokeColor = UIColor.black.cgColor
        bezierLayer.lineWidth = 2
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func draw(_ rect: CGRect) {
        drawPolyline()
        
        let path = UIBezierPath()
        
        path.move(to: point0)
        for t in stride(from: 0, to: 1, by: 0.001) {
            let finalPoint = getPointForCubicBezier(t: t)
            path.addLine(to: finalPoint)
        }
        
        bezierLayer.path = path.cgPath
    }
    
    func drawPolyline() {
        let path = UIBezierPath()
        path.move(to: point0)
        path.addLine(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        UIColor.gray.set()
        path.stroke()
    }
    
    func getPointForCubicBezier(t: Double) -> CGPoint {
        var finalPoint = CGPoint()
        finalPoint.x = pow(1 - t, 3) * point0.x +
                           pow(1 - t, 2) * 3 * t * point1.x +
                           (1 - t) * 3 * t * t * point2.x +
                           t * t * t * point3.x;
        finalPoint.y = pow(1 - t, 3) * point0.y +
                           pow(1 - t, 2) * 3 * t * point1.y +
                           (1 - t) * 3 * t * t * point2.y +
                           t * t * t * point3.y;
        
        return finalPoint
    }
}
