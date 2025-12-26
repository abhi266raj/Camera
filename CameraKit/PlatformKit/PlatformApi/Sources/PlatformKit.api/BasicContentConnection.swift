//
//  BasicContentConnection.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import AVFoundation

public class BasicContentConnection: ContentConnection {
    public var input: any ContentProducer
    public var output: (any ContentReciever)?
    
    public init(input: any ContentProducer, output: (any ContentReciever)?) {
        self.input = input
        self.output = output
        passThroughSetup()
    }
}

public extension ContentConnection {
    func passThroughSetup() {
        self.input.contentProduced = { [weak self] buffer in
            guard let self, let output else {return}
            output.contentOutput(output, didOutput: buffer, from: self)
        }
    }
    
}

public class MediaContentInput: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ContentProducer {
    public var contentProduced: ((CMSampleBuffer) -> Void)?
    override public init() {
        
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        contentProduced?(sampleBuffer)
    }
    
}
