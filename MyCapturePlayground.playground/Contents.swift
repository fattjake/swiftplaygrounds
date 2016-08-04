//: Playground - noun: a place where people can play

import UIKit
import AVFoundation
import PlaygroundSupport

let captureSession = AVCaptureSession()
captureSession.sessionPreset = AVCaptureSessionPresetHigh

let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.back }
let device = devices.first
print(devices)

do {
    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
    if (captureSession.canAddInput(input)) {
        captureSession.addInput(input)
    }
} catch {
    print("error no input")
}

let layer = AVCaptureVideoPreviewLayer()
layer.bounds = CGRect(x: 0, y: 0, width: 500, height: 400)

let viewController = UIViewController()
viewController.view = UIView(frame: layer.bounds)
let view = viewController.view
view?.layer.addSublayer(layer)

captureSession.startRunning()
PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true


