//
//  SampleBufferVideoRecordingWorkerImp.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//


import Foundation
import AVFoundation
import UIKit
import Combine
import CoreKit
import PlatformApi

private enum VideoRecordError: Error {
    case ongoing
    case notRecording
}

class SampleBufferVideoRecordingWorkerImp: SampleBufferVideoRecordingWorker {
   
    
    func connect(producer:AnyProducer<CMSampleBuffer>, reciever: AnyReciever<CMSampleBuffer>?) {
        let receiver:VideoRecorderImp? = nil
        passThroughSetup(producer: producer.content, reciever: output)
        //passThroughSetup(producer, reciever: reciever)
        //passThroughSetup(producer, reciever: receiver)
    }
    
    typealias ConnectionType = CMSampleBuffer

    
    
    var continuation:AsyncThrowingStream<URL, Error>.Continuation?
    
    var output: ContentReciever<CMSampleBuffer>? {
        return videoRecorder
    }
    
    var videoRecorder: VideoRecorderImp? = nil
    
    public init() {
    }
    
   
    
    
    func startRecording(url: URL?) async -> AsyncThrowingStream<URL, Error> {
        let url = url ?? NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
        let stream = AsyncThrowingStream<URL, Error> { continuation in
            guard self.continuation == nil else {
               continuation.finish(throwing: VideoRecordError.ongoing)
                return
            }
            self.continuation = continuation
            let recorder = VideoRecorderImp(outputURL: url)
            recorder.startRecording()
            videoRecorder = recorder
        }
        return stream
       
        
    }
    func stopRecording() async throws  {
        guard let continuation, let videoRecorder else {
            throw VideoRecordError.notRecording
        }
       
        let url = await withCheckedContinuation { continum in
            videoRecorder.stopRecording { url in
                continum.resume(returning: url)
            }
        }
        continuation.yield(url)
        continuation.finish()
        self.continuation = nil
        self.videoRecorder = nil
    }
    
    func saveVideoToLibrary(_ outputFileURL: URL) async throws {
        let mediaSaver = MediaSaver()
        let request: MediaSaveRequest = .video(outputFileURL)
        try await mediaSaver.save(request)
    }

}
