//
//  PlatformFactoryImp.swift
//  CameraKit
//
//  Created by Abhiraj on 18/12/25.
//


import Foundation
import AVFoundation
import PlatformApi
import CoreKit
import UIKit


final class PlatformFactoryImp: PlatformFactory {
    func makeSampleBufferOutputService() -> any SampleBufferVideoRecordingWorker {
        SampleBufferVideoRecordingWorkerImp()
    }
    
    func makePreviewMetalTarget() -> any PreviewMetalTarget {
        PreviewMetalView(frame: .zero)
    }
    
    func makePhotoClickWorker() -> any PhotoClickWorker {
        CameraPhotoCameraService()
    }
    
    func makeBasicVideoRecordWorker() -> any BasicVideoRecordWorker {
        VideoRecordWorkerImp()
    }
    
    
    lazy var effectProcessor = EffectCameraProcessor()
    func makeEffectProcessor() -> any CameraProccessor {
        effectProcessor
    }
    
    func makeSessionService() -> any CameraSessionService {
        CameraSessionHandlerImp()
    }
    
    public init() {}
    
    func makeMetalDisplayCoordinator() -> SampleBufferDisplayCoordinator {
        return CameraMetalDisplayCoordinatorImp()
    }
    
    func makeMultiCameraDisplayCoordinator(avcaptureSession: AVCaptureMultiCamSession) -> CameraDisplayCoordinator {
        MultiCameraDisplayCoordinator(session: avcaptureSession)
        
    }
    
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator {
        CameraLayerDisplayCoordinatorImp(session: avcaptureSession)
    }
    
    
    func makeCameraInput() -> any CameraInput {
        CameraInputImp()
    }
    
    func makeFilterModelSelection() -> FilterModelSelectionStream {
        FilterModelSelectionStreamImpl()
    }
    
}
