//
//  CameraDisplayCoordinatorFactory.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//

import CoreKit

public protocol PlatformFactory {
    func makeMetalDisplayCoordinator<ContentInput>() -> SampleBufferDisplayCoordinator<ContentInput>
    func makeMultiCameraDisplayCoordinator() -> CameraSessionDisplayCoordinator
    func makeVideoLayerDisplayCoordinator() -> CameraSessionDisplayCoordinator
    
    
    func makePhotoClickWorker() -> PhotoClickWorker
    func makeBasicVideoRecordWorker() -> BasicVideoRecordWorker
    
    func makeSampleBufferOutputService<ContentInput>() -> SampleBufferVideoRecordingWorker<ContentInput>
    
    func makeCameraInput() -> CameraInput
    
    func makeSessionService() -> CameraSessionService
    
    func makeEffectProcessor<ContentInput>() -> CameraProccessor<ContentInput>
    
    func makePreviewMetalTarget() -> PreviewMetalTarget
    
    func makeFilterModelSelection() -> FilterModelSelectionStream
}
