//
//  MetalOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 10/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos

@Observable
class SampleBufferCameraRecorderService: CameraContentRecordingService {
    private(set) var outputState:CameraState = .rendering
    
    let videoOutput: VideoOutput
    
    let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    init(videoOutput: VideoOutput) {
        self.videoOutput = videoOutput
    }
    
    func performAction(action: CameraAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        
        if action == .startRecord {
            self.outputState = .switching
           await videoOutput.startRecord()
            self.outputState = .recording
            return true
        }else if action == .stopRecord {
            self.outputState = .switching
            await videoOutput.stopRecord()
            self.outputState = .rendering
            return true
        }
        throw CameraAction.ActionError.unsupported
    }
    
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        videoOutput.videoRecorder?.appendSampleBuffer(sampleBuffer)
    }
}

final class MetalCameraPreviewView: UIView, CameraContentPreviewService {
    var previewView: UIView {
        return self
    }
    
    func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    let metalView: PreviewMetalView

    init(metalView: PreviewMetalView) {
        self.metalView = metalView
        super.init(frame: .zero)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            metalView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
    }
}





