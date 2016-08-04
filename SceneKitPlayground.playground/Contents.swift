//: Playground - noun: a place where people can play

import UIKit
import SceneKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func viewDidLoad() {
        let scene = SCNScene()
        
        for i in 0..<16 {
            let boxNode = makeBoxNode(size: 1)
            boxNode.position = SCNVector3(Double(i) * 1.3, 0, 0)
            scene.rootNode.addChildNode(boxNode)
            
        }
        
        let scnView = SCNView(frame: view.frame)
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.scene = scene
        
        view.addSubview(scnView)
    }
    
    func makeBoxNode(size : CGFloat) -> SCNNode {
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: size * 0.1)
        let boxNode = SCNNode(geometry: box)
        box.materials.first?.diffuse.contents = 
            #imageLiteral(resourceName: "Photo 7-14-16 at 10.32 PM.jpg")
        
        
        return boxNode
    }
}

let viewC = MyViewController()
PlaygroundPage.current.liveView = viewC
PlaygroundPage.current.needsIndefiniteExecution = true
