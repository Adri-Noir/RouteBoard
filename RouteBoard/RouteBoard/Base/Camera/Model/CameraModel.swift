/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that provides the interface to the features of the camera.
*/

import AVFoundation
import SwiftUI
import CoreImage
import os.log

enum CameraSettings {
    case photoTaking
    case videoTaking
}

class CameraModel: NSObject {
    let cameraSetting: CameraSettings
    
    private let captureSession = AVCaptureSession()
    private let photoCapture = PhotoCapture()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    nonisolated let previewSource: PreviewSource
    private var sessionQueue: DispatchQueue = DispatchQueue(label: "RouteBoard.CameraModel")
    
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .unspecified).devices
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        backCaptureDevices
            .filter( { $0.isConnected } )
            .filter( { !$0.isSuspended } )
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    var isPreviewPaused = false
    var frameCounter = 0;
    let YIELD_EVERY_N_FRAME = 4;
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    self.frameCounter += 1
                    if self.frameCounter % self.YIELD_EVERY_N_FRAME == 0 {
                        continuation.yield(ciImage)
                        self.frameCounter = 0;
                    }
                }
            }
        }
    }()
        
    init(cameraSetting: CameraSettings) {
        self.cameraSetting = cameraSetting
        self.previewSource = DefaultPreviewSource(session: captureSession)
        super.init()
        initialize()
    }
    
    private func initialize() {
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        
        var success = false
        
        self.captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        switch(cameraSetting) {
        case .photoTaking:
            captureSession.sessionPreset = .high;
        case .videoTaking:
            captureSession.sessionPreset = .iFrame1280x720
        }
        
        addCameraInput()
        addPreviewOutput()
        addPhotoOutput()
        
        updateVideoOutputConnection()
        photoCapture.updateConfiguration(for: captureDevice!)
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    private func addCameraInput() {
        do {
            self.deviceInput = try addInput(for: captureDevice)
        } catch {
            logger.error("Failed to obtain video input.")
        }
    }
    
    private func addPreviewOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
        
        do {
            try addOutput(videoOutput)
        } catch {
            logger.error("Failed to obtain video output.")
        }
    }
    
    private func addPhotoOutput() {
        do {
            try addOutput(photoCapture.output)
        } catch {
            logger.error("Failed to obtain photo output.")
        }
    }
    

    private func addInput(for device: AVCaptureDevice?) throws -> AVCaptureDeviceInput {
        guard
            let device = device,
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            logger.error("Failed to obtain video input.")
            throw CameraError.addInputFailed
        }
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
        return input
    }
    
    private func addOutput(_ output: AVCaptureOutput) throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = false
            }
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func takePhoto() async -> Image? {
        do {
            let photoFeatures = PhotoFeatures(isLivePhotoEnabled: false, qualityPrioritization: .quality)
            let photo = try await photoCapture.capturePhoto(with: photoFeatures)
            guard let uiImage = UIImage(data: photo.data) else { return nil }
            return Image(uiImage: uiImage)
        } catch {
            logger.error("Failed to take photo: \(error)")
        }
        
        return nil
    }

    private var deviceOrientation: UIDeviceOrientation {
        return .portrait
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        connection.videoRotationAngle = 90;

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}
