//: Playground - noun: a place where people can play

#if os(OSX)
    import Cocoa
    typealias BezierPath = NSBezierPath
    typealias Color = NSColor
    typealias View = NSView
#else
    import UIKit
    typealias BezierPath = UIBezierPath
    typealias Color = UIColor
    typealias View = UIView
#endif

import PlaygroundSupport
import GLKit

public class Particle : NSObject {
    public var position = CGPoint.zero
    public var acceleration = CGPoint.zero
    var velocity = CGPoint.zero
    
    let maxSpeed : CGFloat = 20.0
    
    public override init() {
        super.init()
    }
    
    public func update(time : Double) {
        velocity = acceleration * CGFloat(time)
        if (velocity.length() > maxSpeed) {
            velocity = velocity.normalized() * maxSpeed
        }
        position = position + velocity * CGFloat(time)
    }
}

public class FlowField {
    var time : Float = 0.0
    
    var perlinGenerator = PerlinGenerator()
    
    public init() {
        perlinGenerator.zoom = 40.0
        perlinGenerator.octaves = 3
        perlinGenerator.persistence = 0.4
    }
    
    public func update(updateTime: Float) {
        time += updateTime
    }
    
    public func acceleration(x: Float, y: Float) -> Float {
        return perlinGenerator.perlinNoise(x: x, y: y, z: time, t: 1.0)
    }
}


class ParticleSystemFlowField : View {
    let flowField = FlowField()
    var particles = [Particle]()
    var layers = [CAShapeLayer]()
    
    var currentTime = CFAbsoluteTimeGetCurrent()

    var frameCount = 0
    var frameTime = CFAbsoluteTimeGetCurrent()
    
    override init(frame: CGRect) {
         super.init(frame: frame)
        
        for _ in 0..<25 {
            let particle = Particle()
            var randX = CGFloat(arc4random() % 1000) / 1000.0
            var randY = CGFloat(arc4random() % 1000) / 1000.0
            
            particle.position = CGPoint(x: randX * frame.size.width, y: randY * frame.size.height)
            
            randX = CGFloat(arc4random() % 1000) / 1000.0
            randY = CGFloat(arc4random() % 1000) / 1000.0
            
            particle.acceleration = CGPoint(x: randX, y:randY)
            particles.append(particle)
            
//            let layer = CAShapeLayer()
//            let path = BezierPath(ovalIn: CGRect(x: 0, y: 0, width: 5, height: 5))
//            layer.path = path.cgPath
//            
//            layer.fillColor = Color.gray().cgColor
//            layer.bounds = CGRect(x: 0, y: 0, width: 2, height: 2)
//            layer.position = particle.position
//            
//            layers.append(layer)
//            self.layer.addSublayer(layer)
        }
        
        Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(callUpdate(timer: )), userInfo: nil, repeats: true)
    }
    
    func callUpdate(timer : Timer) {
        update(timeIn: CFAbsoluteTimeGetCurrent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(timeIn : Double) {
        let time = timeIn - currentTime
        for particle in particles {
            let ffValue = flowField.acceleration(x: Float(particle.position.x), y: Float(particle.position.y)) * Float(M_PI)
            
            let acceleration = CGPoint.init(angle: CGFloat(ffValue)) * 5.0
            particle.acceleration = particle.acceleration + acceleration
            
            particle.update(time: time)
            if particle.position.x < 0 {
                particle.position.x = frame.size.width
            }
            if particle.position.x > frame.size.width {
                particle.position.x = 0
            }
            if particle.position.y < 0 {
                particle.position.y = frame.size.height
            }
            if particle.position.y > frame.size.height {
                particle.position.y = 0
            }
            
            
        }
        currentTime = timeIn
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        //update(timeIn: CFAbsoluteTimeGetCurrent())
        
        BezierPath(rect: rect).fill()
        
        for particle in particles {
           let width = 5.0
            let height = 5.0
            let path = BezierPath(ovalIn: CGRect(x: Double(particle.position.x) - width / 2.0, y: Double(particle.position.y) - height / 2.0, width: width, height: height))
            Color.white().set()
            
            path.fill()
//            if let index = particles.index(of: particle) {
//                let layer = layers[index]
//                CATransaction.begin()
//                CATransaction.setDisableActions(true)
//                layer.position = particle.position
//                CATransaction.commit()
//            }
        }
        
        frameCount += 1
        if frameCount >= 1000 {
            frameTime = CFAbsoluteTimeGetCurrent()
            frameCount = 0
        }
        
        let string = AttributedString(string: String(fps()), attributes: [NSForegroundColorAttributeName: Color.white()])
        #if os(OSX)
        string.draw(with: CGRect(x: 0, y: 0, width: 50, height: 20))
        #else
        string.draw(in: CGRect(x: 0, y: 0, width: 50, height: 20))
        #endif
    }
    
    func fps() -> Double {
        return Double(frameCount) / (CFAbsoluteTimeGetCurrent() - frameTime)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

let psff = ParticleSystemFlowField(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
PlaygroundPage.current.liveView = psff

