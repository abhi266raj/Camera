//
//  BasicFileRecorder.swift
//  PlatformKit
//
//  Created by Abhiraj on 06/12/25.
//

@preconcurrency import AVFoundation
internal import Synchronization

class BasicFileRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var fileOutput: AVCaptureMovieFileOutput
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
    public init(fileOutput: AVCaptureMovieFileOutput) {
        self.fileOutput = fileOutput
        super.init()
    }
    
    public func start(_ record: Bool) {
        if record {
            if !isRecording {
                let outputFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
                fileOutput.startRecording(to: outputFilePath, recordingDelegate: self)
            }
        }else {
            fileOutput.stopRecording()
        }
    }
    
    deinit {
            fileOutput.stopRecording()
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            // Handle the error, e.g., display an error message.
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        Task{
            let mediaSaver = MediaSaver()
            let request: MediaSaveRequest = .video(outputFileURL)
            try await mediaSaver.save(request)
        }
    }
    
}

enum RecordingError: Error, Sendable {
    case alreadyRecording
    case notRecording
}

enum RecordingEvent: Sendable {
    case started
    case finished(URL)
    case failed(Error)
}

protocol VideoRecordingAdapter: Sendable {
    func startRecording(to url: URL) throws -> AsyncStream<RecordingEvent>
    func stopRecording() throws
}

final class AVFoundationVideoRecordingAdapter: NSObject, VideoRecordingAdapter, AVCaptureFileOutputRecordingDelegate {

    private let fileOutput: AVCaptureMovieFileOutput
    private let continuation = Mutex<AsyncStream<RecordingEvent>.Continuation?>(nil)

    init(fileOutput: AVCaptureMovieFileOutput) {
        self.fileOutput = fileOutput
        super.init()
    }

    func startRecording(to url: URL) throws -> AsyncStream<RecordingEvent> {
        guard !fileOutput.isRecording else {
            throw RecordingError.alreadyRecording
        }
        
        
        return AsyncStream { streamContinuation in
            self.continuation.withLock { $0 = streamContinuation }

            fileOutput.startRecording(to: url, recordingDelegate: self)
            streamContinuation.yield(.started)

            streamContinuation.onTermination = { termination in
                if termination == .cancelled {
                    try? self.stopRecording()
                }
            }
        }
    }

    func stopRecording() throws {
        guard fileOutput.isRecording else {
            throw RecordingError.notRecording
        }
        fileOutput.stopRecording()
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        continuation.withLock { cont in
            if let error {
                cont?.yield(.failed(error))
            } else {
                cont?.yield(.finished(outputFileURL))
            }
            cont?.finish()
            cont = nil
        }
    }
}
