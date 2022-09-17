import UIKit
import simd

class ViewController: UIViewController, UITextFieldDelegate {
    
    lazy var gridView: GridView = {
        let view = GridView()
        view.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var xScaleValueTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        return textField
    }()
    
    lazy var yScaleValueTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        return textField
    }()
    
    lazy var originYTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        return textField
    }()
    
    lazy var originXTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        return textField
    }()
    
    let controlsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 0.5
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        controlsView.frame = CGRect(x: 0, y: view.bounds.height * 0.75, width: view.bounds.width, height: view.bounds.height * 0.25)
        view.addSubview(controlsView)
        
        view.addSubview(gridView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(gridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(gridView.bottomAnchor.constraint(equalTo: controlsView.topAnchor))
        
        NSLayoutConstraint.activate(constraints)
        
//        controlsView.addSubview(slider)
//        slider.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor).isActive = true
//        slider.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor).isActive = true
//        slider.bottomAnchor.constraint(equalTo: controlsView.bottomAnchor).isActive = true
        
        let scalesLabel = getLabel()
        controlsView.addSubview(scalesLabel)
        scalesLabel.text = "Масштабы: "
        scalesLabel.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor, constant: 5).isActive = true
        scalesLabel.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: 2).isActive = true
        
        xScaleValueTextField.addTarget(self, action: #selector(scaleFieldDiDChange(sender:)), for: .editingChanged)
        controlsView.addSubview(xScaleValueTextField)
        xScaleValueTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        xScaleValueTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        xScaleValueTextField.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor, constant: 10).isActive = true
        xScaleValueTextField.topAnchor.constraint(equalTo: scalesLabel.bottomAnchor, constant: 5).isActive = true
        
        let xLabel = getLabel()
        xLabel.text = "x"
        controlsView.addSubview(xLabel)
        xLabel.centerXAnchor.constraint(equalTo: xScaleValueTextField.centerXAnchor).isActive = true
        xLabel.topAnchor.constraint(equalTo: xScaleValueTextField.bottomAnchor, constant: 5).isActive = true
        
//        let yScaleLabel = getLabel()
//        controlsView.addSubview(yScaleLabel)
//        yScaleLabel.text = "Масштаб по вертикали: "
//        yScaleLabel.leadingAnchor.constraint(equalTo: xLabel.trailingAnchor, constant: 10).isActive = true
//        yScaleLabel.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: 10).isActive = true
        
        yScaleValueTextField.addTarget(self, action: #selector(scaleFieldDiDChange(sender:)), for: .editingChanged)
        controlsView.addSubview(yScaleValueTextField)
        yScaleValueTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        yScaleValueTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        yScaleValueTextField.leadingAnchor.constraint(equalTo: xScaleValueTextField.trailingAnchor, constant: 10).isActive = true
        yScaleValueTextField.topAnchor.constraint(equalTo: scalesLabel.bottomAnchor, constant: 5).isActive = true
        
        let yLabel = getLabel()
        yLabel.text = "y"
        controlsView.addSubview(yLabel)
        yLabel.centerXAnchor.constraint(equalTo: yScaleValueTextField.centerXAnchor).isActive = true
        yLabel.topAnchor.constraint(equalTo: yScaleValueTextField.bottomAnchor, constant: 5).isActive = true
        
//        let xLabelForScaleY = getLabel()
//        xLabelForScaleY.text = "x"
//        controlsView.addSubview(xLabelForScaleY)
//        xLabelForScaleY.leadingAnchor.constraint(equalTo: yScaleValueTextField.trailingAnchor, constant: 5).isActive = true
//        xLabelForScaleY.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: 10).isActive = true
        
        let originsLabel = getLabel()
        controlsView.addSubview(originsLabel)
        originsLabel.text = "Левый верхний угол: "
        originsLabel.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: -5).isActive = true
        originsLabel.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: 2).isActive = true
        
        originYTextField.addTarget(self, action: #selector(originFieldDidChange(sender:)), for: .editingChanged)
        controlsView.addSubview(originYTextField)
        originYTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        originYTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        originYTextField.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: -10).isActive = true
        originYTextField.topAnchor.constraint(equalTo: scalesLabel.bottomAnchor, constant: 5).isActive = true
        
        let yLabelForOrigins = getLabel()
        yLabelForOrigins.text = "y"
        controlsView.addSubview(yLabelForOrigins)
        yLabelForOrigins.centerXAnchor.constraint(equalTo: originYTextField.centerXAnchor).isActive = true
        yLabelForOrigins.topAnchor.constraint(equalTo: originYTextField.bottomAnchor, constant: 5).isActive = true
        
        originXTextField.addTarget(self, action: #selector(originFieldDidChange(sender:)), for: .editingChanged)
        controlsView.addSubview(originXTextField)
        originXTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        originXTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        originXTextField.trailingAnchor.constraint(equalTo: originYTextField.leadingAnchor, constant: -10).isActive = true
        originXTextField.topAnchor.constraint(equalTo: scalesLabel.bottomAnchor, constant: 5).isActive = true
        
        let xLabelForOrigins = getLabel()
        xLabelForOrigins.text = "x"
        controlsView.addSubview(xLabelForOrigins)
        xLabelForOrigins.centerXAnchor.constraint(equalTo: originXTextField.centerXAnchor).isActive = true
        xLabelForOrigins.topAnchor.constraint(equalTo: originXTextField.bottomAnchor, constant: 5).isActive = true
        
        
        slider.addTarget(self, action: #selector(targetChanged), for: .valueChanged)
        gridView.setNeedsDisplay()
        
        view.bringSubviewToFront(controlsView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func targetChanged() {
        gridView.xScale = 2 * slider.value
        gridView.setNeedsDisplay()
    }


    func drawGraph() {
        
    }
    
    @objc func scaleFieldDiDChange(sender: UITextField) {
        
        guard let replacementString = sender.text, var scaleValue = Float(replacementString) else {return}
        
        if scaleValue < 0 {
            scaleValue = -scaleValue
            sender.text = "\(scaleValue)"
        }
        
        if sender == xScaleValueTextField {
            gridView.xScale = scaleValue
        } else {
            gridView.yScale = scaleValue
        }
        
        gridView.setNeedsDisplay()
    }
    
    @objc func originFieldDidChange(sender: UITextField) {
        guard let replacementString = sender.text, let scaleValue = Float(replacementString) else {return}
        
        if sender == originXTextField {
            gridView.originX = scaleValue
        } else {
            gridView.originY = scaleValue
        }
        
//        gridView.xScale = 1
//        gridView.yScale = 1
//        xScaleValueTextField.text = ""
//        yScaleValueTextField.text = ""
        gridView.setNeedsDisplay()
    }
    
    private func getLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               return
            }

        if view.frame.origin.y == 0 {
            view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
}

class GridView: UIView {
    
    var xScale: Float = 1
    var yScale: Float = 1
    
    var originX: Float = 0
    var originY: Float = 0
    
    var origin = CGPoint(x: 0, y: 0)
    
    var isGraphDrawn = false
    
    private let gridCellWidthAndHeight: CGFloat = 15
    
    let figureLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(figureLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        self.layer.addSublayer(figureLayer)
//        drawEmptyGraph()
//
//    }
    
    override func draw(_ rect: CGRect) {
            
        drawEmptyGraph()
        isGraphDrawn = true
        
        let scaleMatrix = makeScaleMatrix(xScale: xScale, yScale: yScale)
               
        let topRightPoint = simd_float3(x: 3, y: 1, z: 1) * scaleMatrix
        let bottomRightPoint = simd_float3(x: 3, y: 3, z: 1) * scaleMatrix
        let bottomLeftPoint = simd_float3(x: 1, y: 3, z: 1) * scaleMatrix
        
        let newTopLeftPoint = CGPoint(x: CGFloat(originX), y: CGFloat(originY))
        let newBottomLeftPoint = CGPoint(x: CGFloat(originX), y: CGFloat(originY - bottomLeftPoint.y))
        let newBottomRightPoint = CGPoint(x: CGFloat(bottomRightPoint.x + originX), y:  CGFloat(originY - bottomLeftPoint.y))
        let newTopRightPoint = CGPoint(x: CGFloat(topRightPoint.x + originX), y: CGFloat(originY))
        
        drawFigure(with: [newTopLeftPoint, newBottomLeftPoint, newBottomRightPoint, newTopRightPoint])
    }
    
    private func drawEmptyGraph() {
        drawAxis(startPoint: CGPoint(x: bounds.width / 2, y: 0), endPoint: CGPoint(x: bounds.width / 2, y: bounds.height))
        drawAxis(startPoint: CGPoint(x: 0, y: bounds.height / 2), endPoint: CGPoint(x: bounds.width, y: bounds.height / 2))
        
        drawGrid()
        isGraphDrawn = true
    }
    
    private func drawAxis(startPoint: CGPoint, endPoint: CGPoint) {
        let ordinateAxis = UIBezierPath()
        ordinateAxis.move(to: startPoint)
        ordinateAxis.addLine(to: endPoint)

        ordinateAxis.lineWidth = 1
        ordinateAxis.stroke()
    }
    
    private func drawGrid() {
        
        var offsetFromCenter: CGFloat = gridCellWidthAndHeight
        var counter = 1
        while (bounds.width / 2) + offsetFromCenter <= bounds.width {
            drawGridLine(from: CGPoint(x: (bounds.width / 2) + offsetFromCenter, y: 0),
                         to: CGPoint(x: (bounds.width / 2) + offsetFromCenter, y: bounds.height))
            if !isGraphDrawn {
                drawNumberLabel(in: CGPoint(x: (bounds.width / 2) + offsetFromCenter + 1, y: (bounds.height / 2) + 1), number: counter)
            }
            offsetFromCenter += 15
            counter += 1
        }
        
        offsetFromCenter = gridCellWidthAndHeight
        counter = 1
        while (bounds.width / 2) - offsetFromCenter >= 0 {
            drawGridLine(from: CGPoint(x: (bounds.width / 2) - offsetFromCenter, y: 0),
                         to: CGPoint(x: (bounds.width / 2) - offsetFromCenter, y: bounds.height))
            if !isGraphDrawn {
                drawNumberLabel(in: CGPoint(x: (bounds.width / 2) - offsetFromCenter + 1, y: (bounds.height / 2) + 1), number: -counter)
            }
            offsetFromCenter += 15
            counter += 1
        }
        
        counter = 1
        offsetFromCenter = gridCellWidthAndHeight
        while (bounds.height / 2) - offsetFromCenter >= 0 {
            drawGridLine(from: CGPoint(x: 0 , y: (bounds.height / 2) - offsetFromCenter),
                         to: CGPoint(x: bounds.width , y: (bounds.height / 2) - offsetFromCenter))
            if !isGraphDrawn {
                drawNumberLabel(in: CGPoint(x: (bounds.width / 2) + 2, y: (bounds.height / 2) - offsetFromCenter - 10), number: counter)
            }
            offsetFromCenter += 15
            counter += 1
        }
        
        offsetFromCenter = gridCellWidthAndHeight
        counter = 1
        while (bounds.height / 2) + offsetFromCenter <= bounds.height {
            drawGridLine(from: CGPoint(x: 0 , y: (bounds.height / 2) + offsetFromCenter),
                         to: CGPoint(x: bounds.width , y: (bounds.height / 2) + offsetFromCenter))
            if !isGraphDrawn {
                drawNumberLabel(in: CGPoint(x: (bounds.width / 2) + 2, y: (bounds.height / 2) + offsetFromCenter + 1), number: -counter)
            }
            offsetFromCenter += 15
            counter += 1
        }
    }
    
    private func drawGridLine(from: CGPoint, to: CGPoint) {
        let line = UIBezierPath()
        line.move(to: from)
        line.addLine(to: to)
        line.lineWidth = 0.5
        
        UIColor.lightGray.setStroke()
        line.fill()
        line.stroke(with: .normal, alpha: 0.5)
    }
    
    private func drawNumberLabel(in point: CGPoint, number: Int) {
        let numberLabel = UILabel(frame: CGRect(x: point.x, y: point.y, width: 10, height: 10))
        numberLabel.text = String(number)
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.textColor = .systemBlue
        addSubview(numberLabel)
    }
    
    private func drawFigure(with coordinates: [CGPoint]) {
        figureLayer.path = nil
        
        let figurePath = UIBezierPath()
        
        let screenCoordinates = transformCartesianCoordinatesToScreenCoordinates(coordinates)
        
        figurePath.move(to: screenCoordinates[0])
        figurePath.addLine(to: screenCoordinates[1])
        figurePath.addLine(to: screenCoordinates[2])
        figurePath.addLine(to: screenCoordinates[3])
        
        figurePath.close()
        
        figureLayer.path = figurePath.cgPath
    }
    
    private func transformCartesianCoordinatesToScreenCoordinates(_ coordinates: [CGPoint]) -> [CGPoint] {
        
        var screenCoordinates = [CGPoint]()
        
        coordinates.forEach {
            let x = (bounds.width / 2) + (gridCellWidthAndHeight * $0.x)
            let y = (bounds.height / 2) - (gridCellWidthAndHeight * $0.y)
            
            screenCoordinates.append(CGPoint(x: x, y: y))
        }
        
        return screenCoordinates
    }
    
    func makeScaleMatrix(xScale: Float, yScale: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(xScale,      0, 0),
            simd_float3(     0, yScale, 0),
            simd_float3(     0,      0, 1)
        ]
        
        return float3x3(rows: rows)
    }
    
    func makeRotationMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), -sin(angle), 0),
            simd_float3(sin(angle), cos(angle), 0),
            simd_float3(0,          0,          1)
        ]
        
        return float3x3(rows: rows)
    }
}

