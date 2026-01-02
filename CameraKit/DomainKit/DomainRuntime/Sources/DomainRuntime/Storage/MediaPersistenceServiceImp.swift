//
//  MediaPersistenceServiceImp.swift
//  CameraKit
//
//  Created by Abhiraj on 02/01/26.
//

import DomainApi
internal import Foundation
import PlatformApi
internal import Photos

struct MediaPersistenceServiceImp: MediaPersistenceService{
    
    enum Error: Swift.Error {
        case permissionDenied
    }
    
    let mediaStorageGateway: MediaPersistenceGateway
    let permissionService: PermissionService
    
    init(mediaStorageGateway: MediaPersistenceGateway, permissionService: PermissionService) {
        self.mediaStorageGateway = mediaStorageGateway
        self.permissionService = permissionService
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

    
    func save(_ request: MediaPersistenceRequest) async throws {
        try await ensurePhotoPermission()
        switch request {
        case .imageData(let data):
            try await mediaStorageGateway.saveImageToPhotoLibrary(data)
        case .video(let url):
            try await mediaStorageGateway.saveVideoToPhotoLibrary(url)
        }
    }
}
