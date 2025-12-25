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
internal import Synchronization


final class CameraPhotoCameraService: NSObject, Sendable {
    let continuationMutex:  Mutex<AsyncThrowingStream<AVCapturePhoto, Error>.Continuation?> = Mutex(nil)
    var continuation:AsyncThrowingStream<AVCapturePhoto, Error>.Continuation? {
        get {
            var result:AsyncThrowingStream<AVCapturePhoto, Error>.Continuation? = nil
            continuationMutex.withLock {result = $0}
            return result
        }
        set {
            continuationMutex.withLock{$0 = newValue}
        }
    }
    
    override public init() {
        
    }
}

extension CameraPhotoCameraService: PhotoClickWorker {
    
    enum PhotoClickError: Error {
        case ongoing
    }
    
    func clickPhoto(_ output: AVCapturePhotoOutput, imageCaptureConfig:ImageCaptureConfig) async -> AsyncThrowingStream<AVCapturePhoto, Error> {
        let stream = AsyncThrowingStream<AVCapturePhoto, Error> { continuation in
            guard self.continuation == nil else {
                continuation.finish(throwing: PhotoClickError.ongoing)
                return
            }
            self.continuation = continuation
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.maxPhotoDimensions = imageCaptureConfig.resolution.maxDimension()
            output.capturePhoto(with: photoSettings, delegate: self)
        }
        return stream
    }
}


extension CameraPhotoCameraService: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?)
    {
        guard error == nil else {
            continuation?.finish(throwing: error)
            return
        }
        
        continuation?.yield(photo)
        continuation?.finish()
        continuation = nil
    }
    
    /// Async method to request permission and save photo
     func savePhotoToLibrary(_ photo: AVCapturePhoto) async throws {
        guard let imageData = photo.fileDataRepresentation() else {
            throw NSError(domain: "CameraService", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to get image data"])
        }
        let mediaSaver = MediaSaver()
        let request: MediaSaveRequest = .imageData(imageData)
        try await mediaSaver.save(request)
        
    }
}

