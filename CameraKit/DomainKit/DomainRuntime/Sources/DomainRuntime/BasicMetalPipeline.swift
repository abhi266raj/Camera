//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

@preconcurrency internal import AVFoundation
import CoreKit
import PlatformApi
import DomainApi
internal import Synchronization

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraSubSystem, @unchecked Sendable {
    
    private let captureSession: AVCaptureSession    
    private let sampleBufferOutputService: SampleBufferVideoRecordingWorker<CMSampleBuffer>
    private let sessionManager: CameraSessionService
    private let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    private let input: CameraInput
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let processor: CameraProccessor<CMSampleBuffer>
    private  let displayCoordinator: any SampleBufferDisplayCoordinator<CMSampleBuffer>
   // let multiContentInput: MultiContentInput
    let audioInput = MediaContentInput()
    let sessionState: SessionState = SessionState()
    let sessionConfig: SessionConfig = SessionConfig()
    let continuation: Mutex<AsyncStream<CameraMode>.Continuation?> = Mutex(nil)
    let bufferCameraInput: MediaContentInput

    
    public init(platformFactory: PlatformFactory, stream: AsyncStream<FilterModel>) {
        let session = AVCaptureSession()
        captureSession = session
      //  multiContentInput = MultiContentInput()
        sampleBufferOutputService = platformFactory.makeSampleBufferOutputService()
        self.processor = platformFactory.makeEffectProcessor()
        sessionManager = platformFactory.makeSessionService()
        bufferCameraInput = MediaContentInput()
        displayCoordinator = platformFactory.makeMetalDisplayCoordinator()
        input = platformFactory.makeCameraInput()
        super.init()
        commonInit()
        Task.immediate {
            await handleFilter(stream: stream)
        }
    }
    
    private func commonInit() {
        let videoQueue = DispatchQueue(label: "videoQueue")
        let audioQueue = DispatchQueue(label: "audioQueue")
        bufferOutput.setSampleBufferDelegate(bufferCameraInput, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(audioInput, queue: audioQueue)
        if let videoDevice = input.backCamera {
            sessionState.selectedVideoDevice = [videoDevice]
        }
        bufferOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        sessionConfig.contentOutput = [bufferOutput,audioOutput]
        sessionConfig.audioDevice = [input.audioDevice].flatMap{$0}
        sessionConfig.videoDevice = sessionState.selectedVideoDevice
        
    }
    
    func handleFilter(stream: AsyncStream<FilterModel>) async {
        for await filter in stream {
            self.processor.selectedFilter = filter
        }
    }
    
    public func setup() async {
        if let _ = await try? sessionManager.apply(sessionConfig, session: captureSession) {
            await captureSession.startRunning()
        }
    }
    
    public func start() async {
            await captureSession.startRunning()
    }
    
    public func stop() async {
        await captureSession.stopRunning()
    }
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
            if let videoInput = displayCoordinator.getBufferProvider() {
                // Sample buffer will have its own reciver
                // let value: ContentReciever<CMSampleBuffer>? = nil
                sampleBufferOutputService.createConnection(producer: videoInput, reciever: nil)
                sampleBufferOutputService.createConnection(producer: audioInput, reciever: nil)
            }
            if let output = displayCoordinator.getBufferReciever() {
                self.processor.createConnection(producer: bufferCameraInput, reciever: output)
            }
            
            
            
        }
    }
    
    public func toggleCamera() async -> Bool {
        let device = toggledDevice()
        await sessionState.update(device)
        sessionConfig.videoDevice = sessionState.selectedVideoDevice
        await try? sessionManager.apply(sessionConfig, session: captureSession)
        return true
   }
    
    private func toggledDevice() -> [AVCaptureDeviceInput] {
        if sessionState.selectedVideoDevice.first?.device.uniqueID == input.frontCamera?.device.uniqueID {
            return [input.backCamera].compactMap { $0 }
        }else {
            return  [input.frontCamera].compactMap { $0 }
        }
    }
    
    var cameraModePublisher: AsyncSequence<CameraMode, Never> {
        let value = AsyncStream<CameraMode>.make()
        continuation.withLock { $0 = value.1}
        return value.0
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        if action == .startRecord {
            continuation.withLock { $0?.yield(.initiatingCapture)}
            let stream = await sampleBufferOutputService.startRecording(url: nil)
            continuation.withLock { $0?.yield(.capture(.video))}
            Task.immediate {
                for try await result in stream {
                    try await sampleBufferOutputService.saveVideoToLibrary(result)
                }
            }
            return true
        }else if action == .stopRecord {
            continuation.withLock { $0?.yield(.initiatingCapture)}
            defer {
                continuation.withLock { $0?.yield(.preview)}
            }
            try await sampleBufferOutputService.stopRecording()
            return true
        }
            throw CameraAction.ActionError.unsupported
        return true
    }
}




