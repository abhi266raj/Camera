import Foundation
import UseCaseApi
import DomainApi
import PlatformApi
import Photos


public struct MediaStorageUseCaseImp: MediaStorageUseCase{
    
    enum Error: Swift.Error {
        case permissionDenied
    }
    
    let mediaStorageGateway: MediaPersistenceGateway
    let permissionService: PermissionService
    
    public init(mediaStorageGateway: MediaPersistenceGateway, permissionService: PermissionService) {
        self.mediaStorageGateway = mediaStorageGateway
        self.permissionService = permissionService
    }
    
    private func ensurePhotoPermission() async throws {
        guard await permissionService.requestAddOnlyPhotoLibraryPermission() else {
            throw Error.permissionDenied
        }
    }

    public func save(_ content: MediaContent) async throws {
        try await ensurePhotoPermission()
        switch content {
        case .imageData(let data):
            try await mediaStorageGateway.saveImageToPhotoLibrary(data)
        case .video(let url):
            try await mediaStorageGateway.saveVideoToPhotoLibrary(url)
        }
    }
}

