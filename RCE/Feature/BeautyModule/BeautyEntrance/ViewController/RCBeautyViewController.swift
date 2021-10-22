//
//  RCBeautyViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/31.
//

import UIKit
import AVFoundation

class RCBeautyViewController: UIViewController {
    
    private lazy var manager = MHBeautyManager()
    private lazy var menuView = RCMHBeautyView(manager)
    
    private lazy var session = AVCaptureSession()
    private lazy var output = AVCaptureVideoDataOutput()
    private lazy var previewImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        return instance
    }()
    private var position: AVCaptureDevice.Position = .front
    
    private lazy var context = CIContext()
    
    private let queue = DispatchQueue(label: "cn.rongcloud.rcrtc.beauty")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(previewImageView)
        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(65.resize)
        }
        setupSession()
        previewImageView.contentMode = .scaleAspectFill
        menuView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewImageView.frame = view.bounds
    }
    
    deinit {
        debugPrint("RCBeautyViewController delloc")
    }

    private func setupSession() {
        
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                         mediaType: .video,
                                                         position: position)
        guard let device = discovery.devices.first else {
            fatalError()
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.setSampleBufferDelegate(self, queue: queue)
        
        let connection = output.connection(with: .video)
        connection?.isEnabled = true
        connection?.videoOrientation = .portrait
        
        session.startRunning()
    }
    
    private func switchCamera() {
        let inputs = session.inputs.compactMap { $0 as? AVCaptureDeviceInput }
        guard let deviceInput = inputs.first else { return }
        
        session.beginConfiguration()
        
        let postion: AVCaptureDevice.Position = {
            switch deviceInput.device.position {
            case .back: return .front
            case .front: return .back
            default: return .front
            }
        }()
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                         mediaType: .video,
                                                         position: postion)
        guard let device = discovery.devices.first else {
            fatalError()
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }
        
        session.removeInput(deviceInput)
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let connection = output.connection(with: .video)
        connection?.isEnabled = true
        connection?.videoOrientation = .portrait
        
        session.commitConfiguration()
        self.position = postion
    }
}

extension RCBeautyViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let fType = CVPixelBufferGetPixelFormatType(pixelBuffer)
        manager.process(with: pixelBuffer, formatType: fType)
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let cgImage = context.createCGImage(ciImage,
                                            from: CGRect(x: 0, y: 0, width: width, height: height),
                                            format: .BGRA8,
                                            colorSpace: CGColorSpaceCreateDeviceRGB())
        if cgImage == nil { return }
        let image = UIImage(cgImage: cgImage!,
                            scale: UIScreen.main.scale,
                            orientation: position == .front ? .upMirrored : .up)
        DispatchQueue.main.async {
            self.previewImageView.image = image
        }
    }
}

extension RCBeautyViewController: RCMHBeautyViewDelegate {
    func didClickBeautyAction(_ action: RCMHBeautyAction) {
    }
}
