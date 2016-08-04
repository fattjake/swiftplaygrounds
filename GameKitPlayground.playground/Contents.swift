//: Playground - noun: a place where people can play

// Based heavily on @FlexMonkey

import UIKit
import GameplayKit
import PlaygroundSupport

public class FlockingSystem {
    let behavior = GKBehavior()
    
    let agentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    let behaviour = GKBehavior()
    
    public var callback : (([GKAgent2D]) -> ())?
    
    public var target = GKAgent2D()
    
    let separateGoal : GKGoal?
    let alignGoal : GKGoal?
    let cohesianGoal : GKGoal?
    let avoidGoal : GKGoal?
    let seekGoal : GKGoal?
    let wanderGoal : GKGoal?
    
    let agentNumber : Int
    
    var weights : [GKGoal : NSNumber]?
    
    lazy var displayLink: CADisplayLink =
        {
            [unowned self] in
            return CADisplayLink(target: self, selector: #selector(FlockingSystem.step))
            }()
    
    
    
    public init(frame : CGRect, number : Int) {
        agentNumber = number
        for _ in 0 ..< agentNumber
        {
            let agent = GKAgent2D()
            agent.position = vector2(50.0, 50.0)
            agent.maxSpeed = 150
            agent.maxAcceleration = 100
            agent.radius = 10
            
            agentSystem.addComponent(agent)
        }
        
        let agents = getGKAgent2D(system: agentSystem)
        
        separateGoal = GKGoal(toSeparateFrom: agents, maxDistance: 10, maxAngle: Float(2 * M_PI))
        alignGoal = GKGoal(toAlignWith: agents, maxDistance: 20, maxAngle: Float(2 * M_PI))
        cohesianGoal = GKGoal(toCohereWith: agents, maxDistance: 20, maxAngle: Float(2 * M_PI))
        avoidGoal = GKGoal(toAvoid: agents, maxPredictionTime: 2)
        seekGoal = GKGoal(toSeekAgent:target)
        wanderGoal = GKGoal(toWander: 25)
        
        weights = [//separateGoal! : 60,
                       alignGoal! : 25,
                       cohesianGoal! : 50,
                       avoidGoal! : 100,
                       seekGoal! : 50,
                        wanderGoal! : 60]
        
        
        for (goal, weight) in weights! {
            behavior.setWeight(Float(weight), for: goal)
        }
        
        for agent in agentSystem.components
        {
            if let agent = agent as? GKAgent2D {
                agent.behavior = behavior
            }
        }
        
        target.position = vector2(Float(frame.width) / 2.0, Float(frame.height) / 2.0)
    }
    
    public func start() {
        displayLink.add(to: RunLoop.main,
                                 forMode: RunLoopMode(rawValue: RunLoopMode(rawValue: RunLoopMode.defaultRunLoopMode.rawValue).rawValue))
    }
    
    public func stop() {
        
    }
    
    @objc func step()
    {
        agentSystem.update(withDeltaTime: 1.0 / 10.0)
        if let callback = callback {
            callback(getGKAgent2D(system: agentSystem))
        }
    }
}

func getGKAgent2D(system : GKComponentSystem<GKComponent>) -> [GKAgent2D] {
    return system.components
                .filter({ $0 is GKAgent2D })
                .map({ $0 as! GKAgent2D })
}

//extension GKComponentSystem
//{
//    func getGKAgent2D() -> [GKAgent2D]
//    {
//        return components
//            .filter({ $0 is GKAgent2D })
//            .map({ $0 as! GKAgent2D })
//    }
//}

class CirclesView : UIView {
    let flockingSystem : FlockingSystem?
    var paths = [UIBezierPath]()
    var pathColors = [UIColor]()
    var pathSizes = [Float]()
    
    let bitmapContext : CGContext
    
    init(frame: CGRect, agentNumber : Int) {
        flockingSystem = FlockingSystem(frame: frame, number: agentNumber)
        
        bitmapContext = CGContext(data: nil, width: Int(frame.size.width), height: Int(frame.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)!
        super.init(frame: frame)
        
        for _ in 0..<agentNumber {
            let random = Float(arc4random() % 1000) / 1000.0
            pathColors.append(UIColor(hue: CGFloat(random), saturation: 0.5, brightness: 1.0, alpha: 1.0))
            
            let randomSize = (Float(arc4random() % 1000) + 1000.0) / 100.0
            pathSizes.append(randomSize)
        }
        
        flockingSystem?.callback = {(agents: [GKAgent2D]) -> () in
            self.paths.removeAll()
            for agent in agents {
                let size = Int(self.pathSizes[agents.index(of: agent)!])
                self.paths.append(UIBezierPath(ovalIn: CGRect(x: Int(agent.position.x), y: Int(agent.position.y), width: size, height: size)))
            }
            self.setNeedsDisplay()
        }
        flockingSystem?.start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let color = UIColor.black
        color.setFill()
        let context = UIGraphicsGetCurrentContext()
        context?.fill(rect)
        
        let drawInBitmap = true
        
        for path in paths {
        
            let color = pathColors[paths.index(of: path)!]
            if (drawInBitmap) {
                bitmapContext.addPath(path.cgPath)
                bitmapContext.setFillColor(color.cgColor)
                bitmapContext.fillPath()
            } else {
                color.setFill()
                path.fill()
            }
        }
        
        if (drawInBitmap) {
            let cgImage = bitmapContext.makeImage()
            context?.draw(in: rect, image: cgImage!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            flockingSystem?.target.position = vector2(Float(touchPoint.x), Float(touchPoint.y))
        }
    }
}

let view = CirclesView(frame: CGRect(x: 0, y: 0, width: 625, height: 625), agentNumber: 10)

PlaygroundPage.current.liveView = view

