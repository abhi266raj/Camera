//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
internal import CoreMedia
import CoreKit
import PlatformApi
import DomainApi
internal import UIKit

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraSubSystem, @unchecked Sendable, CameraRecordingSubSystem {
    
    private let captureSession: AVCaptureSession
    public var recordOutput: CameraDiskOutputService {
        sampleBufferOutputService
    }
    
    private let sampleBufferOutputService: SampleBufferDiskOutputService
    private let sessionManager: CameraSessionService

    private(set) var input: CameraInput
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    let processor: CameraProccessor
    public  let displayCoordinator: any CameraDisplayCoordinator
    private let metalRenderingDelegateImp: MetalRenderingDelegateImp
    private var streamTask : Task<Void, Never>?
    let multiContentInput: MultiContentInput
    let audioInput = MediaContentInput()
    let sessionState: SessionState = SessionState()
    let sessionConfig: SessionConfig = SessionConfig()

    
    public init(platformFactory: PlatformFactory, stream: AsyncStream<FilterModel>) {
        let session = AVCaptureSession()
        self.captureSession = session
        let contentInput = MultiContentInput()
        contentInput.insert(audioInput)
        self.multiContentInput = contentInput
        sampleBufferOutputService = platformFactory.makeSampleBufferOutputService(input: multiContentInput)
        let metalRenderingDelegateImp = MetalRenderingDelegateImp(sampleBufferOutputService: sampleBufferOutputService)
        let effectProcessor = platformFactory.makeEffectProcessor()
        sessionManager = platformFactory.makeSessionService()
        
        let viewBuilder: () -> UIView = {
            
            let metalView = platformFactory.makePreviewMetalTarget()
            let connection = BasicContentConnection(input: metalRenderingDelegateImp.videoInput,output: metalView)
            effectProcessor.setup(connection: connection)
            contentInput.insert(metalView)
            return metalView
        }
        displayCoordinator = platformFactory.makeMetalDisplayCoordinator(builder: viewBuilder)
        self.metalRenderingDelegateImp = metalRenderingDelegateImp
        self.input = platformFactory.makeCameraInput()
        
        self.processor = effectProcessor
        
        super.init()
        bufferOutput.setSampleBufferDelegate(metalRenderingDelegateImp.videoInput, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(audioInput, queue: audioQueue)
        self.streamTask = Task {  @MainActor [weak self] in
            for await filter in stream {
                self?.processor.selectedFilter = filter
            }
        }
        
        if let videoDevice = input.backCamera {
            sessionState.selectedVideoDevice = [videoDevice]
        }
        bufferOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        sessionConfig.contentOutput = [bufferOutput,audioOutput]
        sessionConfig.audioDevice = [input.audioDevice].flatMap{$0}
        sessionConfig.videoDevice = sessionState.selectedVideoDevice
        
    }
    
    @MainActor func handleFilter(stream: AsyncStream<FilterModel>, processor: CameraProccessor?) async {
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
}




class MetalRenderingDelegateImp {
    let videoInput = MediaContentInput()
    let sampleBufferOutputService: SampleBufferDiskOutputService
    
    init(sampleBufferOutputService: SampleBufferDiskOutputService) {
        self.sampleBufferOutputService = sampleBufferOutputService
    }
}




