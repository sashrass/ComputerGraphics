//
//  ViewController.swift
//  comp_graphics_lab5
//
//  Created by Александр Рассохин on 10.11.2022.
//

import UIKit
import Plot3d
import SceneKit

enum NavigationButtonType {
    case up
    case down
    case left
    case right
}

class ViewController: UIViewController {
    
    let edges = [[[Float(1), 1, 0], [1, 4, 0], [4, 4, 0], [4, 1, 0]],
                 [[1, 1, 0], [1, 4, 0], [1, 4, 3], [1, 1, 3]],
                 [[4, 1, 3], [4, 4, 3], [4, 4, 0], [4, 1, 0]],
                 [[1, 4, 3], [1, 4, 0], [4, 4, 0], [4, 4, 3]],
                 [[1, 1, 0], [4, 1, 0], [4, 1, 3], [1, 1, 3]],
                 [[1, 1, 3], [4, 1, 3], [4, 4, 3], [1, 4, 3]]]
    
    var pointsCount: Int {
        return edges.flatMap {$0}.count
    }
    
    lazy var isEdgeVisible  = Array(repeating: false, count: edges.count)

    var position = [Float(6), 6, 6]

    var point = [Float(0), 0, 0]
    
    var plotView: PlotView?
        
    lazy var upButton = getNavigationButton(type: .up)
    lazy var downButton = getNavigationButton(type: .down)
    lazy var leftButton = getNavigationButton(type: .left)
    lazy var rightButton = getNavigationButton(type: .right)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = PlotConfiguration()

        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 150)
        let plotView = PlotView(frame: frame, configuration: config)
        self.plotView = plotView
        view.addSubview(plotView)
        
        view.addSubview(upButton)
        view.addSubview(downButton)
        view.addSubview(rightButton)
        view.addSubview(leftButton)
        
        NSLayoutConstraint.activate([
            upButton.topAnchor.constraint(equalTo: plotView.bottomAnchor, constant: 5),
            upButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            downButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            downButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            
            rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
        plotView.setCamera(position: PlotPoint(6, 6, 6))
        plotView.setCamera(lookAt:  PlotPoint(0, 0, 0))

        plotView.setAxisTitle(.x, text: "x axis", textColor: .white)
        plotView.setAxisTitle(.y, text: "y axis", textColor: .white)
        plotView.setAxisTitle(.z, text: "z axis", textColor: .white)

        plotView.dataSource = self
        plotView.delegate = self
        
        getInsidePoint()
        getVisibleSurfaces()
        plotView.reloadData()
    }
    
    func getVisibleSurfaces() {
        isEdgeVisible = isEdgeVisible.map {_ in false}
        for (index, face) in edges.enumerated() {
            let canonicalForm = getCanonicalForm(point1: face[0], point2: face[1], point3: face[2])
            let visibilityValue = getVisibilityValue(plane: canonicalForm, point1: point, point2: position)
            
            if visibilityValue >= 0, visibilityValue <= 1 {
                isEdgeVisible[index] = true
            }
        }
    }
    
    func getInsidePoint() {
        var count = 0
        for face in edges {
            count += face.count
            var localArr = Array(repeating: Array(repeating: Float(0), count: 4), count: 3)
            for (index, arrElement) in face.enumerated() {
                for (innerIndex, element) in arrElement.enumerated() {
                    localArr[innerIndex][index] = element
                }
            }
            for i in 0..<3 {
                point[i] += Float(localArr[i].reduce(0, +))
            }
        }
        point = point.map {$0 / Float(count) }
    }
    
    func getCanonicalForm(point1: [Float], point2: [Float], point3: [Float]) -> [Float] {
        let x1 = point1[0]
        let y1 = point1[1]
        let z1 = point1[2]
        
        let x2 = point2[0]
        let y2 = point2[1]
        let z2 = point2[2]
        
        let x3 = point3[0]
        let y3 = point3[1]
        let z3 = point3[2]
        
        var result = [Float(0),0,0,0]
        var temp1 = (y2-y1) * (z3-z1)
        var temp2 = (z2-z1) * (y3-y1)
        result[0] = temp1 - temp2
        temp1 = (x2-x1)*(z3-z1)
        temp2 = (z2-z1)*(x3-x1)
        result[1] = -(temp1-temp2)
        temp1 = (x2-x1)*(y3-y1)
        temp2 = (y2-y1)*(x3-x1)
        result[2] = temp1-temp2
        temp1 = -x1*result[0]
        temp2 = y1*result[1]
        result[3] = temp1 - temp2 - z1*result[2]
        
        return result
    }
    
    func getVisibilityValue(plane: [Float], point1: [Float], point2: [Float]) -> Float {
        let a = plane[0]
        let  b = plane[1]
        let  c = plane[2]
        let  d = plane[3]
        
        let   x1 = point1[0]
        let   y1 = point1[1]
        let   z1 = point1[2]
        
        let   x2 = point2[0]
        let   y2 = point2[1]
        let   z2 = point2[2]
        
        let visibilityValue = (-d-a*x1-b*y1-c*z1)/(a*(x2-x1)+b*(y2-y1)+c*(z2-z1))
        
        return visibilityValue
    }
    
    func getNavigationButton(type: NavigationButtonType) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .up:
            button.setTitle("^", for: .normal)
        case .down:
            button.setTitle("˅", for: .normal)
        case .left:
            button.setTitle("<", for: .normal)
        case .right:
            button.setTitle(">", for: .normal)
        }
        
        button.addAction(UIAction(handler: { _ in
            
            switch type {
            case .up:
                self.position[1] += 1
            case .down:
                self.position[1] -= 1
            case .left:
                self.position[0] -= 1
            case .right:
                self.position[0] += 1
            }
            
            
            self.plotView?.setCamera(position: PlotPoint(CGFloat(self.position[0]), CGFloat(self.position[1]), CGFloat(self.position[2])))
            self.plotView?.setCamera(lookAt: PlotPoint(CGFloat(0), CGFloat(0), CGFloat(0)))
            self.getVisibleSurfaces()
            self.plotView?.reloadData()
        }), for: .touchUpInside)
        
        return button
    }

}

extension ViewController: PlotDataSource, PlotDelegate {
    func plot(_ plotView: Plot3d.PlotView, pointForItemAt index: Int) -> Plot3d.PlotPoint {
        let planeIndex = index / 4
        let pointIndex = index % 4
        let point = edges[planeIndex][pointIndex]
        
        return PlotPoint(CGFloat(point[0]), CGFloat(point[1]), CGFloat(point[2]))
        
    }

    func numberOfPoints() -> Int {
        return pointsCount
    }

    func plot(_ plotView: Plot3d.PlotView, geometryForItemAt index: Int) -> SCNGeometry? {
        let geo = SCNSphere(radius: 0.05)
        let pointIndex = index % 4
        let planeIndex = index / 4
        let point = edges[planeIndex][pointIndex]
        if isEdgeVisible[planeIndex] {
            print(point)
            geo.materials.first!.diffuse.contents = UIColor.red
        } else {
            geo.materials.first!.diffuse.contents = UIColor.clear
        }
        
        return geo
    }

    func numberOfConnections() -> Int {
        return pointsCount
    }
    
    func plot(_ plotView: PlotView, pointsToConnectAt index: Int) -> (p0: Int, p1: Int)? {
        
        let planeIndex = index / 4
        
        if isEdgeVisible[planeIndex] {
            if ((index + 1) % 4 == 0 && index != 0) || index == pointsCount - 1 {
                return (index, index - 3)
            } else {
                return (index, index + 1)
            }
        } else {
            return nil
        }
        
    }
    
    func plot(_ plotView: PlotView, connectionAt index: Int) -> PlotConnection? {
        return PlotConnection(radius: 0.01, color: .green)
    }
    

}

