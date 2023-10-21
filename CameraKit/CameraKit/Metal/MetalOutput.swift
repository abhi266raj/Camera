//
//  MetalOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 10/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos


class VideoRecordingOutput {
    var videoRecorder: VideoRecorder?
    let videoSaver: VideoSaver  = VideoSaver()
}

extension VideoRecordingOutput {
    
    func startRecord() {
        if videoRecorder == nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let videoOutputPath = (documentsPath as NSString).appendingPathComponent("output.mov")
            let videoOutputURL = URL(fileURLWithPath: videoOutputPath)
            
            let recorder = VideoRecorder(outputURL: videoOutputURL)
            recorder.startRecording()
            videoRecorder = recorder
            
        }
        
    }
    
    func stopRecord() {
        let recorder = videoRecorder
        videoRecorder = nil
        recorder?.stopRecording { url in
            self.videoSaver.save(outputFileURL: url, error: nil)
            // Handle recording completion here
            //self.videoRecorder = nil
        }
    }
    
}



class MetalOutput: CameraOutput {
    
    var videoOutput: VideoRecordingOutput = VideoRecordingOutput()
    
    var supportedOutput: CameraOutputAction = [.filterView, .startRecord, .stopRecord]
    
    
    private var session:AVCaptureSession
    var previewView: UIView
    var metalView: PreviewMetalView
    
    init(session: AVCaptureSession) {
        self.session = session
        metalView = PreviewMetalView(frame: CGRectMake(0, 0, 1080/4, 1920/4))
        previewView = UIView(frame: CGRectMake(0, 0, 1080/4, 1920/4))
        previewView.addSubview(metalView)
        //previewView.backgroundColor = .green
        metalView.backgroundColor = .yellow
    
        
        
    }
    
    func updateFrame () {
        if previewView.bounds != CGRectZero {
            metalView.frame = previewView.bounds
        }
   }
    
    func performAction(action: CameraOutputAction) throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraOutputAction.ActionError.invalidInput
        }
        
        if action == .startRecord {
            videoOutput.startRecord()
            return true
        }else if action == .stopRecord {
            videoOutput.stopRecord()
            return true
        }
        throw CameraOutputAction.ActionError.unsupported
       
    }
    
}





