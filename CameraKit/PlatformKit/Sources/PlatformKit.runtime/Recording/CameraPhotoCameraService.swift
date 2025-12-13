//
//  CameraPhotoCameraService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Combine
import Foundation
import AVFoundation
import Photos
import CoreKit
import PlatformKit_api

public class CameraPhotoCameraService: NSObject, CameraContentRecordingService, @unchecked Sendable {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    
    var photoOutput:AVCapturePhotoOutput
    public var imageCaptureConfig =  ImageCaptureConfig()
    
    override public init() {
        self.photoOutput = AVCapturePhotoOutput()
    }
    
    public func performAction(action: CameraAction) throws -> Bool {
        guard action == .photo else {
            throw CameraAction.ActionError.invalidInput
        }
        cameraModePublisher.send(.capture(.photo))
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.maxPhotoDimensions = imageCaptureConfig.resolution.maxDimension()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        
        throw CameraAction.ActionError.unsupported
       
    }
    
    public var availableOutput: [AVCaptureOutput] {
        return [photoOutput]
    }
}

private struct UnsafePhoto: @unchecked Sendable {
    let photo: AVCapturePhoto
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
        
        
        
        let unsafePhoto = UnsafePhoto(photo: photo)
        Task {
            do {
                try await self.savePhotoToLibrary(unsafePhoto)
                self.cameraModePublisher.send(.preview)
                print("Image saved to Photos library")
            } catch {
                self.cameraModePublisher.send(.preview)
                print("Failed to save photo: \(error.localizedDescription)")
            }
        }
    }
    
    /// Async method to request permission and save photo
    private func savePhotoToLibrary(_ photo: UnsafePhoto) async throws {
        guard let imageData = photo.photo.fileDataRepresentation() else {
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

