//
//  VideoSaveHelper.swift
//  CameraKit
//
//  Created by Abhiraj on 21/10/23.
//

import Foundation
internal import Photos
import PlatformApi

class VideoSaverImp2 {
    
    
    func save(outputFileURL: URL, error: Error?) {
       if let error = error {
           // Handle the error, e.g., display an error message.
           print("Error recording video: \(error.localizedDescription)")
           return
       }
       
       // Request permission to access the photo library.
       PHPhotoLibrary.requestAuthorization { status in
           if status == .authorized {
               // If permission is granted, save the video to the gallery.
               PHPhotoLibrary.shared().performChanges {
                   let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                   request?.creationDate = Date()
               } completionHandler: { success, error in
                   if success {
                       // Video saved successfully.
                       print("Video saved to the gallery.")
                   } else if let error = error {
                       // Handle the error, e.g., display an error message.
                       print("Error saving video to the gallery: \(error.localizedDescription)")
                   }
                   
                   // Optionally, you can delete the temporary file.
                   do {
                       try FileManager.default.removeItem(at: outputFileURL)
                   } catch {
                       print("Error deleting temporary file: \(error.localizedDescription)")
                   }
               }
           } else {
               // Handle the case where permission is denied.
               print("Permission to access the photo library denied.")
           }
       }
   }
    
}

/// Internal VideoSaver implementation using Swift concurrency and AsyncStream.
internal final class VideoSaverImp: VideoSaver, Sendable {
//    func save(outputFileURL: URL, error: (any Error)?) {
//        let url = outputFileURL
//        Task { [url] in
//            try? await saveVideo(at: url)
//        }
//        
//    }
    
    
    /// Represents error states of the video saving process.
    internal enum VideoSaveError: Error {
        /// Permission to access photo library was denied.
        case permissionDenied
        /// Failed to save video with underlying error.
        case saveFailed(Error)
        /// Failed to delete temporary file with underlying error.
        case deletionFailed(Error)
    }
    
    /// Represents the result states of the video saving process.
    internal enum VideoSaveResult {
        /// Video saved successfully.
        case success
        /// Permission to access photo library was denied.
        case permissionDenied
        /// Failed with an error.
        case failure(VideoSaveError)
        /// Temporary file deleted successfully.
        case fileDeleted
    }
    
    /**
     Request permission to add items to the photo library.
     
     - Returns: `true` if permission granted, `false` otherwise.
     */
    private func requestAddOnlyPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return status == .authorized
    }

   
    private func ensurePhotoPermission() async throws {
        guard await requestAddOnlyPhotoLibraryPermission() else {
            throw VideoSaveError.permissionDenied
        }
    }
    
    func saveVideo(from url: URL) async throws {
        try await ensurePhotoPermission()
        try await saveToPhotoLibrary(at: url)
        try deleteFile(url)
    }

    func saveToPhotoLibrary(at url: URL) async throws {
        guard await requestAddOnlyPhotoLibraryPermission() else {
            throw VideoSaveError.permissionDenied
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }

        
    }

    private func deleteFile(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

