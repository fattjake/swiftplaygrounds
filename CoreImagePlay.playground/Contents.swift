//: Playground - noun: a place where people can play

import UIKit
import AVFoundation
import CoreImage
import GLKit
import PlaygroundSupport

class CaptureViewController : GLKViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession = AVCaptureSession()
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDispatchQueue = DispatchQueue(label: "com.capture.video")
    
    var ciContext : CIContext?
    //let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    override func viewDidLoad() {
        
        let glView = self.view as! GLKView
        glView.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        ciContext = CIContext(eaglContext: glView.context)
        
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.back }
        let device = devices.first
        
        do {
            let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
            }
        } catch {
            print("error no input")
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDispatchQueue)
        
        if (captureSession.canAddOutput(videoDataOutput)) {
            captureSession.addOutput(videoDataOutput)
        }
        captureSession.commitConfiguration()
        
        
        //        sampleBufferDisplayLayer.bounds = self.view.bounds
        //        sampleBufferDisplayLayer.position = self.view.center
        //self.view.layer.addSublayer(sampleBufferDisplayLayer)
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let image = CIImage(cvImageBuffer: videoPixelBuffer)
            if let filter = CIFilter(name: "CISepiaTone") {
                filter.setValue(image, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    ciContext?.draw(outputImage, in: CGRect(x: 0, y:0, width: self.view.frame.size.width * 2.0, height: self.view.frame.size.height * 2.0), from: outputImage.extent)
                }
            }
        }
    }
}

let viewController = CaptureViewController()
PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
