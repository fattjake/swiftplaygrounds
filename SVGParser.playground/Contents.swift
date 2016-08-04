//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport



let url = Bundle.main.url(forResource: "placeholder", withExtension: "svg")
let parser = SVGParser(SVGURL: url!, containerLayer: nil, shouldParseSinglePathOnly: false)

//let path = UIBezierPath.pathWithSVGURL(SVGURL: url!)

let view = UIView(frame: CGRect(x: 0, y: 0, width: 475, height: 485))
let layer = CAShapeLayer()
let layerTwo = CAShapeLayer()

layer.path = parser.paths[0].cgPath
layerTwo.path = parser.paths[1].cgPath

view.layer.backgroundColor = UIColor.white.cgColor
view.layer.addSublayer(layer)
view.layer.addSublayer(layerTwo)



PlaygroundPage.current.liveView = view
