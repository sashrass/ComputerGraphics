//
//  ViewController.swift
//  CompGraph_la3
//
//  Created by Александр Рассохин on 28.10.2022.
//

import UIKit
import simd
import Plot3d
import SceneKit

class ViewController: UIViewController {
    
    let a = 15
    var points: [Point] = []
    var startPoints = [Point]()
    var plotView: PlotView?
    
    let xSlider: UISlider = UISlider()
    let ySlider: UISlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        view.addSubview(xSlider)
        view.addSubview(ySlider)
        
        xSlider.translatesAutoresizingMaskIntoConstraints = false
        ySlider.translatesAutoresizingMaskIntoConstraints = false
        ySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        ySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        ySlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        
        xSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        xSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        xSlider.bottomAnchor.constraint(equalTo: ySlider.topAnchor, constant: -10).isActive = true
        
        xSlider.addTarget(self, action: #selector(rotateByX), for: .touchUpOutside)
        ySlider.addTarget(self, action: #selector(rotateByY), for: .touchUpOutside)
        xSlider.addTarget(self, action: #selector(rotateByX), for: .touchUpInside)
        ySlider.addTarget(self, action: #selector(rotateByY), for: .touchUpInside)
        
        let createdPoints = createPoints(count: 4, start: 6, stop: 12)
        
        // [Point(x: 2.7, y: -1.4, z: 0.8), Point(x: -2.6, y: -1.8, z: 2.7), Point(x: -2.4, y: 2.3, z: -1.9), Point(x: -2.7, y: -1.5, z: 1.5)]
        
        let pts = createPointsForSurface(vertices: createdPoints)
        self.points = pts.horizontal.flatMap {$0} + pts.vertical.flatMap {$0}
        self.startPoints = self.points

        let config = PlotConfiguration()

        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 150)
        let plotView = PlotView(frame: frame, configuration: config)
        self.plotView = plotView
        view.addSubview(plotView)
        
        plotView.setCamera(position: PlotPoint(10, 6, 10))
        plotView.setCamera(lookAt: PlotPoint(0, 0, 0))

        plotView.setAxisTitle(.x, text: "x axis", textColor: .white)
        plotView.setAxisTitle(.y, text: "y axis", textColor: .white)
        plotView.setAxisTitle(.z, text: "z axis", textColor: .white)
        
        plotView.dataSource = self
        plotView.delegate = self
        plotView.reloadData()
    }

    func createPoints(count: Int, start: Float, stop: Float, step: Float = 0.1) -> [Point]{
        
        var points = [Point]()
        var numbersList: [Float] = []
        var result = start
        
        while result < stop {
            numbersList.append(result.rounded(toPlaces: 1))
            result += step
        }
        
        for _ in 0..<count {
            points.append(Point(x: numbersList.randomElement()!, y: numbersList.randomElement()!, z: numbersList.randomElement()!))
        }
        
        return points
    }
    
    func makeXRotationMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(1,      0,               0),
            simd_float3(0, cos(angle), -sin(angle)),
            simd_float3(0, sin(angle),  cos(angle))
        ]

        return float3x3(rows: rows)
    }
    
    func makeYRotationMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), 0, sin(angle)),
            simd_float3(0,           1,         0),
            simd_float3(-sin(angle), 0,  cos(angle))
        ]

        return float3x3(rows: rows)
    }
    
    func createPointsForSurface(vertices: [Point]) -> (horizontal: [[Point]], vertical: [[Point]]) {
        
        var points: (horizontal: [[Point]], vertical: [[Point]]) = ([], [])
     
        for i in 0...a {
            points.horizontal.append([])
            let u = Float(i) / Float(a)
            for j in 0...a {
                let w = Float(j) / Float(a)
                let x = (1 - u) * (1 - w) * vertices[0].x + (1 - u) * w * vertices[1].x + u * (1 - w) * vertices[2].x + u * w * vertices[3].x
                let y = (1 - u) * (1 - w) * vertices[0].y + (1 - u) * w * vertices[1].y + u * (1 - w) * vertices[2].y + u * w * vertices[3].y
                let z = (1 - u) * (1 - w) * vertices[0].z + (1 - u) * w * vertices[1].z + u * (1 - w) * vertices[2].z + u * w * vertices[3].z

                let point = Point(x: x, y: y, z: z)
                points.horizontal[i].append(point)
            }
        }
        
        for i in 0...a {
            points.vertical.append([])
            let w = Float(i) / Float(a)
            for j in 0...a {
                let u = Float(j) / Float(a)
                let x = (1 - u) * (1 - w) * vertices[0].x + (1 - u) * w * vertices[1].x + u * (1 - w) * vertices[2].x + u * w * vertices[3].x
                let y = (1 - u) * (1 - w) * vertices[0].y + (1 - u) * w * vertices[1].y + u * (1 - w) * vertices[2].y + u * w * vertices[3].y
                let z = (1 - u) * (1 - w) * vertices[0].z + (1 - u) * w * vertices[1].z + u * (1 - w) * vertices[2].z + u * w * vertices[3].z

                let point = Point(x: x, y: y, z: z)
                points.vertical[i].append(point)
            }
        }

        return points
    }
    
    @objc func rotateByX() {
        ySlider.value = 0
        let angle = (360 * xSlider.value) * .pi / 180
        print("angle: \(angle)")
        let rotationMatrix = makeXRotationMatrix(angle: angle)
        
        let rotatedPoints = startPoints.map { point -> Point in
            let rotated = rotationMatrix * simd_float3(x: point.x, y: point.y, z: point.z)
            return Point(x: rotated.x, y: rotated.y, z: rotated.z)
        }
        self.points = rotatedPoints
        plotView?.reloadData()
    }
    
    @objc func rotateByY() {
        xSlider.value = 0
        let angle = (360 * ySlider.value) * .pi / 180
        print("angle: \(angle)")
        let rotationMatrix = makeYRotationMatrix(angle: angle)
        
        let rotatedPoints = startPoints.map { point -> Point in
            let rotated = rotationMatrix * simd_float3(x: point.x, y: point.y, z: point.z)
            return Point(x: rotated.x, y: rotated.y, z: rotated.z)
        }
        self.points = rotatedPoints
        plotView?.reloadData()
    }
}


extension ViewController: PlotDataSource, PlotDelegate {
    func plot(_ plotView: Plot3d.PlotView, pointForItemAt index: Int) -> Plot3d.PlotPoint {
        
        return points[index].plotPoint
    }
    
    func numberOfPoints() -> Int {
        print("points count = \(points.count)")
        return points.count
    }
    
    func plot(_ plotView: Plot3d.PlotView, geometryForItemAt index: Int) -> SCNGeometry? {
        let geo = SCNSphere(radius: 0.01)
        geo.materials.first!.diffuse.contents = UIColor.red
        return geo
    }
    
    func plot(_ plotView: PlotView, textAtTickMark index: Int, forAxis axis: PlotAxis) -> PlotText? {
        let config = PlotConfiguration()
        switch axis {
        case .x:
            return PlotText(text: "\(index + 1)", fontSize: 0.3, offset: 0.25)
        case .y:
            return PlotText(text: "\(Int(CGFloat(index + 1) * config.yTickInterval))", fontSize: 0.3, offset: 0.1)
        case .z:
            return PlotText(text: "\(index + 1)", fontSize: 0.3, offset: 0.25)
        }
    }
    
    func numberOfConnections() -> Int {
        return points.count
    }
    
    //Connect the points in a way that creates a double helix.
    func plot(_ plotView: PlotView, pointsToConnectAt index: Int) -> (p0: Int, p1: Int)? {
        print("index + 1: \(index + 1)")
        if (index + 1) % (a+1) == 0 {
            print("nil")
            return nil
        }
        else {
            return (p0: index, p1: index + 1)
        }

    }

    //Define the geometry of each connection.
    func plot(_ plotView: PlotView, connectionAt index: Int) -> PlotConnection? {
        return PlotConnection(radius: 0.01, color: .green)
    }

}

struct Point {
    var x: Float
    var y: Float
    var z: Float
    
    var plotPoint: PlotPoint {
        return PlotPoint(CGFloat(x), CGFloat(y), CGFloat(z))
    }
}

extension Float {

    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
