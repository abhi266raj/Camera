//
//  BasicContentConnection.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import AVFoundation
 
public extension ContentConnection  {
        
    func passThroughSetup(producer: ContentProducer<ConnectionType>, reciever: ContentReciever<ConnectionType>?) {
                producer.contentProduced = { [weak self, weak reciever] buffer in
                    guard let self, let reciever else {return}
                    reciever.contentOutput(reciever, didOutput: buffer, from: self)
                }
    }
}

public class MediaContentInput: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ContentProducer {
    public typealias Content = CMSampleBuffer
    public var contentProduced: ((CMSampleBuffer) -> Void)?
    override public init() {
        
    }
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        contentProduced?(sampleBuffer)
    }
}
