//
//  VideoRecordWorkerImp.swift
//  CameraKit
//
//  Created by Abhiraj on 26/12/25.
//

@preconcurrency import AVFoundation
import PlatformApi
internal import Synchronization

final class VideoRecordWorkerImp: NSObject, AVCaptureFileOutputRecordingDelegate, BasicVideoRecordWorker {
    
    let continuationMutex:  Mutex<AsyncThrowingStream<URL, Error>.Continuation?> = Mutex(nil)
    var continuation:AsyncThrowingStream<URL, Error>.Continuation? {
        get {
            var result:AsyncThrowingStream<URL, Error>.Continuation? = nil
            continuationMutex.withLock {result = $0}
            return result
        }
        set {
            continuationMutex.withLock{$0 = newValue}
        }
    }
    
    enum VideoRecordError: Error {
        case ongoing
        case notRecording
    }
    
    
    func startRecording(_ output: AVCaptureMovieFileOutput, url: URL? = nil) async -> AsyncThrowingStream<URL, Error> {
        let url = url ?? NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
        let stream = AsyncThrowingStream<URL, Error> { continuation in
            guard self.continuation == nil else {
               continuation.finish(throwing: VideoRecordError.ongoing)
                return
            }
            self.continuation = continuation
            output.startRecording(to: url, recordingDelegate: self)
        }
        return stream
    }
    
    func stopRecording(output: AVCaptureMovieFileOutput) throws {
        if self.continuation == nil || output.isRecording == false  {
            throw VideoRecordError.notRecording
        }
        output.stopRecording()
    }
        
    
     func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        guard error == nil else {
            continuation?.finish(throwing: error)
            return
        }
        
        continuation?.yield(outputFileURL)
        continuation?.finish()
        continuation = nil
    }
    
    func saveVideoToLibrary(_ outputFileURL: URL) async throws {
        let mediaSaver = MediaSaver()
        let request: MediaSaveRequest = .video(outputFileURL)
        try await mediaSaver.save(request)
   }
    
}
