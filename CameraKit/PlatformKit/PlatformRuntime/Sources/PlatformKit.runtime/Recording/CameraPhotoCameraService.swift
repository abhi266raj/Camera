//
//  CameraPhotoCameraService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Combine
import Foundation
@preconcurrency import AVFoundation
internal import Photos
import CoreKit
import PlatformApi

class CameraPhotoCameraService: NSObject, AVCaptureDiskOutputService, @unchecked Sendable {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    
    var photoOutput:AVCapturePhotoOutput
    public let imageCaptureConfig: ImageCaptureConfig
    
     public init(imageCaptureConfig:ImageCaptureConfig) {
        self.imageCaptureConfig = imageCaptureConfig
        self.photoOutput = AVCapturePhotoOutput()
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        guard action == .photo else {
            throw CameraAction.ActionError.invalidInput
        }
        cameraModePublisher.send(.capture(.photo))
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.maxPhotoDimensions = imageCaptureConfig.resolution.maxDimension()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        return true
       
    }
    
    public var availableOutput: [AVCaptureOutput] {
        return [photoOutput]
    }
}


extension CameraPhotoCameraService: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?)
    {
        guard error == nil else {
            cameraModePublisher.send(.preview)
            return
        }
        
        Task {
            do {
                try await self.savePhotoToLibrary(photo)
                self.cameraModePublisher.send(.preview)
                print("Image saved to Photos library")
            } catch {
                self.cameraModePublisher.send(.preview)
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
        let mediaSaver = MediaSaver()
        let request: MediaSaveRequest = .imageData(imageData)
        try await mediaSaver.save(request)
        
    }
}

