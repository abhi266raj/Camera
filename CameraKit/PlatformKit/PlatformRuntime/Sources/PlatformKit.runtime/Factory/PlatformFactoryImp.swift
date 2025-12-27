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
import CoreMedia


final class PlatformFactoryImp: PlatformFactory {
    func makeSampleBufferOutputService<ContentInput>() -> SampleBufferVideoRecordingWorker<ContentInput> {
        SampleBufferVideoRecordingWorkerImp()  as! SampleBufferVideoRecordingWorker<ContentInput>
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
    
        
    func makeEffectProcessor<ContentInput>() -> CameraProccessor<ContentInput> {
        EffectCameraProcessor() as! CameraProccessor<ContentInput>
    }
    
    func makeSessionService() -> any CameraSessionService {
        CameraSessionHandlerImp()
    }
    
    public init() {}
    
    func makeMultiCameraDisplayCoordinator() -> CameraSessionDisplayCoordinator {
        MultiCameraDisplayCoordinator()
        
    }
    
    func makeVideoLayerDisplayCoordinator() -> CameraSessionDisplayCoordinator {
        CameraLayerDisplayCoordinatorImp()
    }
    
    
    func makeCameraInput() -> any CameraInput {
        CameraInputImp()
    }
    
    func makeFilterModelSelection() -> FilterModelSelectionStream {
        FilterModelSelectionStreamImpl()
    }
    
    func makeMetalDisplayCoordinator<ContentInput>() -> SampleBufferDisplayCoordinator<ContentInput> {
            return CameraMetalDisplayCoordinatorImp() as! SampleBufferDisplayCoordinator<ContentInput>
    }
}
