//
//  CameraOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine


public protocol CameraContentPreviewService {
    var previewView: UIView {get}
    func updateFrame()
}


public protocol CameraContentRecordingService {
    var supportedOutput: CameraAction {get}
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    
}

public protocol CameraOutputService {
    
    associatedtype PreviewService: CameraContentPreviewService
    associatedtype RecordingService: CameraContentRecordingService
    
    var previewService: PreviewService {get}
    var recordingService: RecordingService {get}
}

final class CameraPreviewView: UIView, CameraContentPreviewService {
    var previewView: UIView {
        return self
    }
    
    func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private let previewLayer: AVCaptureVideoPreviewLayer

    init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = .resizeAspectFill
        super.init(frame: .zero)
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

class CameraPhotoCameraService: NSObject, CameraContentRecordingService {
    var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    
    var photoOutput:AVCapturePhotoOutput
    
    
    init(photoOutput: AVCapturePhotoOutput) {
        self.photoOutput = photoOutput
    }
    
    func performAction(action: CameraAction) throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        cameraModePublisher.send(.capture(.photo))
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        
        throw CameraAction.ActionError.unsupported
       
    }
    
    var supportedOutput: CameraAction = [.photo]
}

class CameraPhotoOutputImp: CameraOutputService {
   
    let previewService: CameraPreviewView
    let recordingService: CameraPhotoCameraService
    
    init(session: AVCaptureSession, photoOutput: AVCapturePhotoOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraPhotoCameraService(photoOutput: photoOutput)
    }
}

class CameraRecordingCameraService: CameraContentRecordingService {
    var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    let videoCaptureOutput:AVCaptureMovieFileOutput
    var fileRecorder: BasicFileRecorder?
    let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    init(videoCaptureOutput: AVCaptureMovieFileOutput) {
        self.videoCaptureOutput = videoCaptureOutput
    }
    
    func performAction(action: CameraAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        if action == .startRecord {
            cameraModePublisher.send(.initiatingCapture)
            fileRecorder = BasicFileRecorder(fileOutput: videoCaptureOutput)
            await fileRecorder?.start(true)
            cameraModePublisher.send(.capture(.video))
            return true
        }else if action == .stopRecord {
            cameraModePublisher.send(.initiatingCapture)
            await fileRecorder?.start(false)
            cameraModePublisher.send(.preview)
            return true
        }
            throw CameraAction.ActionError.unsupported
        }
    
    //var supportedOutput: CameraOutputAction = [.normalView, .startRecord, .stopRecord]
}


class CameraVideoOutputImp: CameraOutputService {
    let previewService: CameraPreviewView
    let recordingService: CameraRecordingCameraService
    
    init(session: AVCaptureSession, videoCaptureOutput: AVCaptureMovieFileOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraRecordingCameraService(videoCaptureOutput: videoCaptureOutput)
    }
}

extension CameraPhotoCameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?)
    {
        guard error == nil else {
            cameraModePublisher.send(.preview)
            return
        }
        
        Task {
            do {
                try await savePhotoToLibrary(photo)
                cameraModePublisher.send(.preview)
                print("Image saved to Photos library")
            } catch {
                cameraModePublisher.send(.preview)
                print("Failed to save photo: \(error.localizedDescription)")
            }
        }
    }
    
    /// Async method to request permission and save photo
    private func savePhotoToLibrary(_ photo: AVCapturePhoto) async throws {
        guard let imageData = photo.fileDataRepresentation() else {
            throw NSError(domain: "CameraService", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to get image data"])
        }
        
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized else {
            throw NSError(domain: "CameraService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
            } completionHandler: { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(domain: "CameraService", code: 2,
                                                          userInfo: [NSLocalizedDescriptionKey: "Unknown error saving photo"]))
                }
            }
        }
    }
}
