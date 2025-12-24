//
//  VideoSaveHelper.swift
//  CameraKit
//
//  Created by Abhiraj on 21/10/23.
//

import Foundation
internal import Photos
import PlatformApi
import UIKit

/// Enum representing what kind of media to save.
enum MediaSaveRequest {
    case image(UIImage)
    case video(URL)
    case imageFromURL(URL)
    case imageData(Data)
}

/// Generic MediaSaver supporting images and videos.
final class MediaSaver: Sendable {
    enum Error: Swift.Error {
        case permissionDenied
        case invalidImageData
        case saveFailed(Swift.Error)
    }
    
    private func requestAddOnlyPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return status == .authorized
    }

    private func ensurePhotoPermission() async throws {
        guard await requestAddOnlyPhotoLibraryPermission() else {
            throw Error.permissionDenied
        }
    }

    func save(_ request: MediaSaveRequest) async throws {
        try await ensurePhotoPermission()
        do {
            switch request {
            case .image(let image):
                try await saveImageToPhotoLibrary(image)
            case .video(let url):
                try await saveVideoToPhotoLibrary(url)
            case .imageFromURL(let url):
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    throw Error.invalidImageData
                }
                try await saveImageToPhotoLibrary(image)
            case .imageData(let data):
                try await saveImageToPhotoLibrary(data)
            }
        } catch {
            throw Error.saveFailed(error)
        }
    }

    private func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    private func saveVideoToPhotoLibrary(_ url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
    
    private func saveImageToPhotoLibrary(_ data: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }
    }
}

extension MediaSaver: VideoSaver {
    func saveVideo(from url: URL) async throws {
        try  await save(.video(url))
    }
}
