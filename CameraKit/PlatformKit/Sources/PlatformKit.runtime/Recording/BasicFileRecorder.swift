//
//  BasicFileRecorder.swift
//  PlatformKit
//
//  Created by Abhiraj on 06/12/25.
//

import Foundation
import AVFoundation
import Photos

public class BasicFileRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var fileOutput: AVCaptureMovieFileOutput
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
    public init(fileOutput: AVCaptureMovieFileOutput) {
        self.fileOutput = fileOutput
        super.init()
    }
    
    public func start(_ record: Bool) {
        if record {
            if !isRecording {
                let outputFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
                fileOutput.startRecording(to: outputFilePath, recordingDelegate: self)
            }
        }else {
            fileOutput.stopRecording()
        }
    }
    
    deinit {
            fileOutput.stopRecording()
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
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
