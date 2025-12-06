//
//  VideoOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 21/10/23.
//

import Foundation


protocol VideoOutput {
    func startRecord() async
    func stopRecord() async
    var videoSaver: VideoSaver {get}
    var videoRecorder: VideoRecorder? {get}
}

class VideoOutputImp {
    var videoRecorder: VideoRecorder?
    let videoSaver: VideoSaver  = VideoSaverImp()
}

extension VideoOutputImp: VideoOutput {
    
    func startRecord() async {
        if videoRecorder == nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let videoOutputPath = (documentsPath as NSString).appendingPathComponent("output.mov")
            let videoOutputURL = URL(fileURLWithPath: videoOutputPath)
            
            let recorder = VideoRecorder(outputURL: videoOutputURL)
            recorder.startRecording()
            videoRecorder = recorder
            
        }
        
    }
    
    func stopRecord() async  {
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
