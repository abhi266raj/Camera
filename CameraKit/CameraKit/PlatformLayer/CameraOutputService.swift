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


public protocol CameraContentPreviewService {
    var previewView: UIView {get}
    func updateFrame()
}


public protocol CameraContentRecordingService {
    var supportedOutput: CameraAction {get}
    var outputState: CameraState {get}
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
    var outputState: CameraState = .idle
    
    var photoOutput:AVCapturePhotoOutput
    
    
    init(photoOutput: AVCapturePhotoOutput) {
        self.photoOutput = photoOutput
    }
    
    func performAction(action: CameraAction) throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        
        let photoSettings = AVCapturePhotoSettings()
        //photoSettings.isAutoStillImageStabilizationEnabled = true
        
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

@Observable
class CameraRecordingCameraService: CameraContentRecordingService {
    var outputState: CameraState = .idle
    let videoCaptureOutput:AVCaptureMovieFileOutput
    var fileRecorder: BasicFileRecorder?
    let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    init(videoCaptureOutput: AVCaptureMovieFileOutput) {
        self.videoCaptureOutput = videoCaptureOutput
        self.outputState = .rendering
    }
    
    func performAction(action: CameraAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        if action == .startRecord {
            self.outputState = .switching
            fileRecorder = BasicFileRecorder(fileOutput: videoCaptureOutput)
            await fileRecorder?.start(true)
            self.outputState = .recording
            return true
        }else if action == .stopRecord {
            self.outputState = .switching
            await fileRecorder?.start(false)
            self.outputState = .rendering
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


extension CameraPhotoCameraService : AVCapturePhotoCaptureDelegate {
    
    // AVCapturePhotoCaptureDelegate method to handle captured photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Save the captured image to the Photos library
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: imageData, options: nil)
                    } completionHandler: { success, error in
                        if success {
                            // The image was successfully saved to the Photos library
                            DispatchQueue.main.async {
                                // Handle UI updates or feedback to the user if needed
                                print("Image saved to Photos library")
                            }
                        } else if let error = error {
                            // Handle the error
                            print("Error saving image to Photos library: \(error.localizedDescription)")
                        }
                    }
                } else {
                    // Handle the case where permission to access the Photos library is denied
                    print("Permission to access Photos library denied")
                }
            }
        }
    }
}





