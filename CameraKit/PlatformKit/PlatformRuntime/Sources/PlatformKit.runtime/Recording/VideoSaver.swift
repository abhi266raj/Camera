//
//  VideoSaveHelper.swift
//  CameraKit
//
//  Created by Abhiraj on 21/10/23.
//

import Foundation
internal import Photos
import PlatformApi

class VideoSaverImp: VideoSaver {
    
    
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
