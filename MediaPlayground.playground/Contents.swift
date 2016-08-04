//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let viewController = PlayerViewController()

//let url = Bundle.main.url(forResource: "Frost of the Mind", withExtension: "mp3")

//let url = URL(string: "https://vimeo.com/21168008/download?t=1466318286&v=69032100&s=c88c68033b66519acb35986df3823137f0830457b4aa1a1966ca548e5ba7375b")

let url = Bundle.main.url(forResource:"laser", withExtension: "mp4")

viewController.view.frame = CGRect(x: 0, y: 0, width: 500, height: 400)

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true

viewController.playerController.playURL(url: url!)
viewController.playerController.setVolume(volume: 1.0)
