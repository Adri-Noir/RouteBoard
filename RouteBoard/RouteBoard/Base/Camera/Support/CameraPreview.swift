@preconcurrency import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {

  private let source: PreviewSource
  private let cornerRadius: CGFloat = 20

  init(source: PreviewSource) {
    self.source = source
  }

  func makeUIView(context: Context) -> PreviewView {
    let preview = PreviewView(cornerRadius: cornerRadius)
    source.connect(to: preview)
    return preview
  }

  func updateUIView(_ previewView: PreviewView, context: Context) {
  }

  class PreviewView: UIView, PreviewTarget {
    private let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 20) {
      self.cornerRadius = cornerRadius
      super.init(frame: .zero)
      self.layer.cornerRadius = cornerRadius
      self.clipsToBounds = true

      #if targetEnvironment(simulator)
        let blueView = UIView(frame: UIScreen.main.bounds)
        blueView.backgroundColor = .blue
        blueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blueView.layer.cornerRadius = cornerRadius
        blueView.clipsToBounds = true
        addSubview(blueView)
      #endif
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override class var layerClass: AnyClass {
      AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
      layer as! AVCaptureVideoPreviewLayer
    }

    nonisolated func setSession(_ session: AVCaptureSession) {
      Task { @MainActor in
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = cornerRadius
      }
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      previewLayer.frame = bounds
    }
  }
}

protocol PreviewSource: Sendable {
  func connect(to target: PreviewTarget)
}

protocol PreviewTarget {
  func setSession(_ session: AVCaptureSession)
}

struct DefaultPreviewSource: PreviewSource {

  private let session: AVCaptureSession

  init(session: AVCaptureSession) {
    self.session = session
  }

  func connect(to target: PreviewTarget) {
    target.setSession(session)
  }
}
