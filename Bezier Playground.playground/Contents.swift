//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class ShapesView : UIView, TouchesToPathViewDelegate {
    let pathLayer = PathLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(pathLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func newPath(path : UIBezierPath) {
        let newPathLayer = PathLayer()
        layer.addSublayer(newPathLayer)
        //why is all this nilling necessary?
        newPathLayer.shouldStroke = true
        newPathLayer.path = path
        newPathLayer.path = nil
        
        pathLayer.path = nil
        pathLayer.path = nil
        pathLayer.setNeedsLayout()
    }
    func tempPath(path: UIBezierPath) {
        pathLayer.path = path
    }
}

var mainView = UIView(frame: CGRect(x: 0, y: 0, width: 615, height: 825))
var view = TouchesToPathView(frame : CGRect(x: 0, y: 0, width: 1200, height: 875))
view.backgroundColor = UIColor.clear()

var shapesView = ShapesView(frame: CGRect(x: 0, y: 0, width: 1200, height: 875))
view.delegate = shapesView

shapesView.layer.backgroundColor = UIColor.gray().cgColor

mainView.addSubview(shapesView)
mainView.addSubview(view)

PlaygroundPage.current.liveView = mainView

