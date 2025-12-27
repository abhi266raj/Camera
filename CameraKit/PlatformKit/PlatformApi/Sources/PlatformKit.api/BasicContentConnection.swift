//
//  BasicContentConnection.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import AVFoundation

//public class BasicContentConnection: ContentConnection {
//    public var input: any ContentProducer
//    public var output: (any ContentReciever)?
//    
//    public init(input: any ContentProducer, output: (any ContentReciever)?) {
//        self.input = input
//        self.output = output
//        passThroughSetup(input, reciever:output)
//    }
//    
//    public func setUpConnection(_ producer: ContentProducer, reciever: ContentReciever?) {
//        passThroughSetup(producer, reciever: reciever)
//    }
//}

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

public class EmptyVideoOutput: ContentReciever {
    public func contentOutput(_ output: any ContentReciever, didOutput sampleBuffer: CMSampleBuffer, from connection: any ContentConnection) {
    }
    
    public typealias Content = CMSampleBuffer
}
