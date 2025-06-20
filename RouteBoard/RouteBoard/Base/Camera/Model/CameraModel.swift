/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
An object that provides the interface to the features of the camera.
*/

import AVFoundation
import CoreImage
import CoreVideo
import SwiftUI
import os.log

class CameraModel: NSObject {
  let shouldDelegatePreview: Bool

  private let captureSession = AVCaptureSession()
  private let photoCapture = PhotoCapture()
  private let ciContext = CIContext()
  private var isCaptureSessionConfigured = false
  private var deviceInput: AVCaptureDeviceInput?
  private var videoOutput: AVCaptureVideoDataOutput?
  nonisolated let previewSource: PreviewSource
  private var sessionQueue: DispatchQueue = DispatchQueue(label: "RouteBoard.CameraModel")
  private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?

  private var allCaptureDevices: [AVCaptureDevice] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInDualCamera], mediaType: .video, position: .unspecified
    ).devices
  }

  private var backCaptureDevices: [AVCaptureDevice] {
    allCaptureDevices
      .filter { $0.position == .back }
  }

  private var availableCaptureDevices: [AVCaptureDevice] {
    backCaptureDevices
      .filter({ $0.isConnected })
      .filter({ !$0.isSuspended })
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

  private var addToPreviewStream: ((UIImage) -> Void)?

  var isPreviewPaused = false
  var frameCounter = 0
  let YIELD_EVERY_N_FRAME = 4

  lazy var previewStream: AsyncStream<UIImage> = {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      addToPreviewStream = { uiImage in
        if !self.isPreviewPaused {
          self.frameCounter += 1
          if self.frameCounter % self.YIELD_EVERY_N_FRAME == 0 {
            continuation.yield(uiImage)
            self.frameCounter = 0
          }
        }
      }
    }
  }()

  init(shouldDelegatePreview: Bool = false) {
    self.shouldDelegatePreview = shouldDelegatePreview
    self.previewSource = DefaultPreviewSource(session: captureSession)
    super.init()
    initialize()
  }

  private func initialize() {
    captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
    if let captureDevice = captureDevice {
      self.rotationCoordinator = AVCaptureDevice.RotationCoordinator(
        device: captureDevice, previewLayer: nil)
    }
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
  }

  private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {

    var success = false

    self.captureSession.beginConfiguration()

    defer {
      self.captureSession.commitConfiguration()
      completionHandler(success)
    }

    captureSession.sessionPreset = .high

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
    videoOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
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

    // Update the rotation coordinator with the new device
    if let captureDevice = self.captureDevice {  // Ensure captureDevice is not nil
      self.rotationCoordinator = AVCaptureDevice.RotationCoordinator(
        device: captureDevice, previewLayer: nil)
    }

    updateVideoOutputConnection()
  }

  private func updateVideoOutputConnection() {
    if let videoOutput = videoOutput,
      let videoOutputConnection = videoOutput.connection(with: .video)
    {
      if videoOutputConnection.isVideoMirroringSupported {
        videoOutputConnection.isVideoMirrored = false
      }
    }
  }

  func start() async throws {
    let authorized = await checkAuthorization()
    guard authorized else {
      logger.error("Camera access was not authorized.")
      throw CameraError.videoDeviceUnavailable
    }

    if isCaptureSessionConfigured {
      if !captureSession.isRunning {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
          sessionQueue.async {
            self.captureSession.startRunning()
            continuation.resume()
          }
        }
      }
      return
    }

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      sessionQueue.async { [self] in
        self.configureCaptureSession { success in
          if success {
            self.captureSession.startRunning()
            continuation.resume()
          } else {
            logger.error("Failed to configure capture session.")
            continuation.resume(throwing: CameraError.setupFailed)
          }
        }
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

  func takePhoto() async -> UIImage? {
    guard captureSession.isRunning else { return nil }
    guard let photoOutput = photoCapture.output as? AVCapturePhotoOutput,
      captureSession.outputs.contains(where: { $0 == photoOutput })
    else {
      logger.error(
        "Attempted to take photo but photo output is not attached or not an AVCapturePhotoOutput.")
      return nil
    }

    // Set the orientation on the photo output connection before capturing
    if let photoOutputConnection = photoOutput.connection(with: .video) {
      // Always set to portrait orientation (90 degrees) for the captured photo
      photoOutputConnection.videoRotationAngle = 90.0
    } else {
      logger.warning(
        "Could not get photo output connection or rotation coordinator to set orientation.")
    }

    do {
      let photoFeatures = PhotoFeatures(isLivePhotoEnabled: false, qualityPrioritization: .quality)
      let capturePhotoResult = try await photoCapture.capturePhoto(with: photoFeatures)

      let dataFromPhoto = capturePhotoResult.data

      // Create UIImage and normalize its orientation to .up
      guard let image = UIImage(data: dataFromPhoto) else {
        logger.error("Failed to create UIImage from photo data.")
        return nil
      }
      let finalImage = image.fixedOrientation()
      return finalImage

    } catch {
      logger.error("Failed to take photo: \(error)")
    }

    return nil
  }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard shouldDelegatePreview && !isPreviewPaused else { return }

    connection.videoRotationAngle = 90

    guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
    // Lock the pixel buffer to safely access its base address.
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    let ciImage = CIImage(cvImageBuffer: pixelBuffer)

    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

    let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)

    addToPreviewStream?(uiImage)
  }
}

// Add extension to normalize UIImage orientation
extension UIImage {
  fileprivate func fixedOrientation() -> UIImage {
    guard imageOrientation != .up else { return self }
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(in: CGRect(origin: .zero, size: size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return normalizedImage
  }
}
