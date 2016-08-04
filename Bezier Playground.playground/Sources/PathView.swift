import UIKit

public class PathLayer : CALayer {
    public var path : UIBezierPath? {
        didSet (path) {
            
            shapeLayer.path = path?.cgPath
            secondShapeLayer.path = path?.cgPath
        }
    }
    
    var shapeLayer = CAShapeLayer()
    var secondShapeLayer = CAShapeLayer()
    var timer : Timer?
    
    public var shouldStroke = false
    
    public var pathLength : CGFloat = 0.25
    public var pathPosition : CGFloat = 0.0
    public var pathSpeed : CGFloat = 0.02
    
    public var strokeColor : UIColor? {
        didSet (color) {
            if let cgColor = color?.cgColor {
                shapeLayer.strokeColor = cgColor
                secondShapeLayer.strokeColor = cgColor
            }
        }
    }
    
    public var fillColor : UIColor? {
        didSet (color) {
            if let cgColor = color?.cgColor {
                shapeLayer.fillColor = cgColor
                secondShapeLayer.fillColor = cgColor
            }
        }
    }
    
    public var lineWidth : CGFloat = 0.0 {
        didSet (lineWidth) {
            shapeLayer.lineWidth = lineWidth
            secondShapeLayer.lineWidth = lineWidth
        }
    }
    
    public convenience init(path aPath : UIBezierPath) {
        self.init()
        path = aPath
    }
    
    public override init() {
        super.init()
        
        addSublayer(shapeLayer)
        addSublayer(secondShapeLayer)
        
        shapeLayer.strokeColor = UIColor.black().cgColor
        shapeLayer.fillColor = UIColor.clear().cgColor
        
        secondShapeLayer.strokeColor = UIColor.black().cgColor
        secondShapeLayer.fillColor = UIColor.clear().cgColor
        
        backgroundColor = UIColor.white().cgColor
        
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(PathLayer.update), userInfo:nil , repeats: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(timer : Timer) {
        if (!shouldStroke) {
            return
        }
        
        pathPosition += pathSpeed
        pathPosition = CGFloat(round(pathPosition * 1000) / 1000)
        
        if (pathPosition >= 1.0) {
            pathPosition -= 1.0
        }
        
        
        var color = UIColor(hue: pathPosition, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        if ((strokeColor) != nil) {
            color = strokeColor!
        }
        
        if (lineWidth == 0) {
            shapeLayer.lineWidth = (CGFloat(arc4random() % 200) / 40.0) + 1.0
            //print(shapeLayer.lineWidth)
            secondShapeLayer.lineWidth = shapeLayer.lineWidth
        }
        
        if (pathPosition + pathLength >= 1.0) {
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            let start = pathPosition
            let end = pathPosition + pathLength
            
            shapeLayer.strokeStart = start
            shapeLayer.strokeEnd = 1.0
            shapeLayer.strokeColor = color.cgColor
            
            secondShapeLayer.strokeStart = 0.0
            secondShapeLayer.strokeEnd = max(end - 1.0, 0.0)
            secondShapeLayer.strokeColor = color.cgColor
            
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            let start = pathPosition
            let end = pathPosition + pathLength
            
            secondShapeLayer.fillColor = UIColor.clear().cgColor
            secondShapeLayer.strokeColor = UIColor.clear().cgColor
//            secondShapeLayer.strokeStart = start
//            secondShapeLayer.strokeEnd = end
            
            shapeLayer.strokeStart = start
            shapeLayer.strokeEnd = end
            shapeLayer.strokeColor = color.cgColor
            
            CATransaction.commit()
        }
    }
}

public protocol TouchesToPathViewDelegate {
    func newPath(path : UIBezierPath)
    func tempPath(path: UIBezierPath)
}

public class TouchesToPathView : UIView {
    var points = [CGPoint]()
    public var delegate : TouchesToPathViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var pathCreationCallback : ((path : UIBezierPath) -> ())?
    public var pathDisplayCallback : ((path : UIBezierPath) -> ())?
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        points.removeAll()
        
        if let touch = touches.first {
            let point = touch.location(in: self)
            points.append(point)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            points.append(point)
        }
        if (points.count > 2) {
            if let path = UIBezierPath(catmullRomPoints: points, closed: true, alpha: 1.0) {
                if let delegate = delegate {
                    delegate.tempPath(path: path)
                }
                if let displayCallback = pathDisplayCallback {
                    displayCallback(path: path)
                }
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let path = UIBezierPath(catmullRomPoints: points, closed: true, alpha: 1.0) {
            if let delegate = delegate {
                delegate.newPath(path: path)
            }
            if let creationCallback = pathCreationCallback {
                creationCallback(path: path)
            }
        }
    }
}

