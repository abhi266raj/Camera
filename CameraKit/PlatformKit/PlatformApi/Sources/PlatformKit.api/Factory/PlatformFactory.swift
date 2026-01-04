//
//  CameraDisplayCoordinatorFactory.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//

import CoreKit

public protocol PlatformFactory<MetalContentInput> {
    associatedtype MetalContentInput
    func makeMetalDisplayCoordinator() -> SampleBufferDisplayCoordinator<MetalContentInput>
    func makeMultiCameraDisplayCoordinator() -> CameraSessionDisplayCoordinator
    func makeVideoLayerDisplayCoordinator() -> CameraSessionDisplayCoordinator
    
    
    func makePhotoClickWorker() -> PhotoClickWorker
    func makeBasicVideoRecordWorker() -> BasicVideoRecordWorker
    
    func makeSampleBufferOutputService() -> SampleBufferVideoRecordingWorker<MetalContentInput>
    
    func makeCameraInput() -> CameraInput
    
    func makeSessionService() -> CameraSessionService
    
    func makeEffectProcessor() -> CameraProccessor<MetalContentInput>
    
    func makePreviewMetalTarget() -> PreviewMetalTarget
    
    func makeFilterModelSelection() -> FilterModelSelectionStream
    
    // func makeMediaPersistenceGateweay() -> MediaPersistenceGateway
}
