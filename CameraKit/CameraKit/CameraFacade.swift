//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import Observation

protocol  Camera {
    
}

enum CameraState {
    case unknown
    case permissionDenied
    case active
    case paused
}


@Observable class CameraManager: Camera {
    
    @ObservationIgnored var cameraPermission: PermissionHandler = CameraPermissionHandler()
    var state: CameraState = .unknown
    @ObservationIgnored var cameraInputManger: any CameraPipelineProtocol = CameraPipeline()
    
    @MainActor public func setup() async {
        if state == .unknown {
            let permission = await  cameraPermission.requestForPermission()
            if permission == false {
                self.state = .permissionDenied
            }else {
                cameraInputManger.setup()
                self.state = .active
            }
        }
        
        
    }
    
}
