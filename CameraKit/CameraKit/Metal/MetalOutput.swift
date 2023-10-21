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

class MetalOutput: CameraOutput {
    
    let videoOutput: VideoOutput
    
    var supportedOutput: CameraOutputAction = [.filterView, .startRecord, .stopRecord]
    
    
    private var session:AVCaptureSession
    var previewView: UIView
    var metalView: PreviewMetalView
    
    init(session: AVCaptureSession, videoOutput: VideoOutput = VideoOutputImp()) {
        self.session = session
        self.videoOutput = videoOutput
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
    
    func performAction(action: CameraOutputAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraOutputAction.ActionError.invalidInput
        }
        
        if action == .startRecord {
           await videoOutput.startRecord()
            return true
        }else if action == .stopRecord {
            await videoOutput.stopRecord()
            return true
        }
        throw CameraOutputAction.ActionError.unsupported
       
    }
    
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        videoOutput.videoRecorder?.appendSampleBuffer(sampleBuffer)
    }
    
}





