//
//  ViewController.swift
//  MotionSensor_POC
//
//  Created by apple  on 21/09/24.
//

import UIKit
import Vision
import AVFoundation
import SwiftOSC


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private var oscManager: OSCManager?
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the OSC Manager to use port 8000
        oscManager = OSCManager(port: 8000)//9000 listening on ios app server

        // Load a sample image for testing
        if let image = UIImage(named: "poseDetection.png") {
            processStaticImage(image)
        }
        self.oscManager?.sendOSCMessage(address: OSCAddressPattern("/gesture"), arguments: ["dataArray hello world"])

    }
    // MARK: - Button Actions
    @IBAction func didTapLoadImageButton(_ sender: UIButton) {
        //saveImageButton.isHidden = true
        
        // stop capture session for canera feed
        captureSession.stopRunning()
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        setupCamera()
    }
    
    // MARK: - Process static image
    func processStaticImage(_ image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }
        let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                  orientation: .init(image.imageOrientation),
                                                  options: [:])
        
        do {
            try requestHandler.perform([bodyPoseRequest])
        } catch {
            print("Can't make the request due to \(error)")
        }

        guard let results = bodyPoseRequest.results else { return }
                
        let normalizedPoints = results.flatMap { result in
            result.availableJointNames
                .compactMap { try? result.recognizedPoint($0) }
                .filter { $0.confidence > 0.1 }
        }
        
        
        
        //let points = normalizedPoints.map { $0.location(in: image) }
        let upsideDownPoints = normalizedPoints.map { $0.location(in: image) }

        let points = upsideDownPoints
            .map { $0.translateFromCoreImageToUIKitCoordinateSpace(using: image.size.height) }
        
        sendPointsToServer(points: points)
        
        self.imageView.image = image.draw(points:  points,
                                           fillColor: .red,
                                           strokeColor: .white)
    }
    
    
    // MARK: - Set up camera capture (for real-time video)
    /// Set up camera capture (for real-time video): You'll need to configure an AVCaptureSession to get a video feed from the camera.
    func setupCamera() {
        captureSession.sessionPreset = .medium

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }

        } catch {
            print("Error setting up camera: \(error)")
        }
    }

    // MARK: - Process each frame of video stream from camera
    // Delegate method to process each frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Step 1: Convert CMSampleBuffer to CVPixelBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Step 2: Convert CVPixelBuffer to CIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Now you can use the CIImage for further processing
        detectPose(on: ciImage)
    }

    // MARK: - Detect post from every frame(image) captured
    func detectPose(on image: CIImage) {
        let request = VNDetectHumanBodyPoseRequest { (request, error) in
        }
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
        
        guard let results = request.results else { return }
        let normalizedPoints = results.flatMap { result in
            result.availableJointNames
                .compactMap { try? result.recognizedPoint($0) }
                .filter { $0.confidence > 0.1 }
        }
        
        //let points = normalizedPoints.map { $0.location(in: image) }
        let image = UIImage(ciImage: image)
        let upsideDownPoints = normalizedPoints.map { $0.location(in: image) }

        let points = upsideDownPoints
            .map { $0.translateFromCoreImageToUIKitCoordinateSpace(using: image.size.height) }
        
        sendPointsToServer(points: points)
        
        DispatchQueue.main.async {
            // Create an image
            let image = image.draw(points:  points,
                                   fillColor: .red,
                                   strokeColor: .white)

            self.imageView.transform = CGAffineTransform(rotationAngle: .pi / 2)
            self.imageView.image = image
        }
    }
    
    // MARK: - Send the captured points to server
    func sendPointsToServer(points : [CGPoint]){
        if points.count > 0{
            var dataArray : [OSCType] = []
            for point in points{
                dataArray.append(String(describing: point))
            }
            self.oscManager?.sendOSCMessage(address: OSCAddressPattern("/gesture"), arguments: dataArray)
        }
    }
}
// MARK: - Image picker from gallery delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
        
        self.imageView.image = info[.originalImage] as? UIImage
        if let image = imageView.image {
            processStaticImage(image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

