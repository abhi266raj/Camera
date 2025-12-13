//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import Observation
import Combine
import CoreKit
import PlatformKit_api
import DomainKit_api
// import DomainKit_runtime

@Observable public class CameraViewModel: @unchecked Sendable {
    
    public init(permissionService: PermissionService, cameraConfig: CameraConfig , cameraService: CameraService) {
        self.permissionService = permissionService
        self.cameraConfig = cameraConfig
        self.cameraService = cameraService
        setup()
    }
    
    func setup() {
        cameraService.cameraModePublisher.sink { [weak self] mode in
            guard let self else {return }
            self.cameraMode = mode
            if case .active(_) = self.cameraPhase {
                self.cameraPhase = .active(mode)
            }
        }.store(in: &cancellables)
    }
    
    private var cameraMode: CameraMode = .preview
    public var cameraPhase: CameraPhase = .inactive
    private var cancellables = Set<AnyCancellable>()
    private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    public var cameraPermissionState: PermissionStatus = .unknown
    private let cameraService:CameraService
    
    public var showCamera: Bool {
        return cameraConfig.supportedTask == .capturePhoto
    }
    
    public var showFilter: Bool {
        return cameraConfig.renderMode == .metal
    }
    
    public var showRecording: Bool {
        return cameraConfig.supportedTask == .recordVideo
    }
    
    @MainActor public func setup() async {
        if cameraPermissionState == .unknown {
            let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
            if permission == false {
                cameraPermissionState = .denied
            }else {
                await cameraService.setup()
                cameraPermissionState = .authorized
                cameraPhase = .active(cameraMode)
            }
        }
    }
    
    public func getOutputView() -> CameraDisplayOutput {
        return cameraService.getOutputView()
        
    }
    
    public func toggleCamera() async  -> Bool {
        cameraPhase = .switching
        let value =  await cameraService.toggleCamera()
        cameraPhase = .active(cameraMode)
        return value
    }
    
    public func performAction( action: CameraAction) async throws -> Bool {
        return try await cameraService.performAction(action:action)
    }
    
}

