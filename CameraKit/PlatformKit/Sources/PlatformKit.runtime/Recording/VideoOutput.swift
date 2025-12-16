//
//  VideoOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 21/10/23.
//

import Foundation
import PlatformKit_api


class VideoOutputImp {
    public var videoRecorder: VideoRecorder?
    public let videoSaver: VideoSaver  = VideoSaverImp()
    public init() {
        
    }
}

extension VideoOutputImp: VideoOutput {
    
    public func startRecord() async {
        if videoRecorder == nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let videoOutputPath = (documentsPath as NSString).appendingPathComponent("output.mov")
            let videoOutputURL = URL(fileURLWithPath: videoOutputPath)
            
            let recorder = VideoRecorderImp(outputURL: videoOutputURL)
            recorder.startRecording()
            videoRecorder = recorder
            
        }
        
    }
    
    public func stopRecord() async  {
        guard let recorder = videoRecorder else {return }
        videoRecorder = nil
        return await withCheckedContinuation { continum in
            recorder.stopRecording { url in
                self.videoSaver.save(outputFileURL: url, error: nil)
                continum.resume()
            }
            
        }
        
    }
    
}
