//
//  CameraLayerDisplayCoordinatorImp.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import PlatformApi
import CoreKit


final class CameraLayerDisplayCoordinatorImp: CameraDisplayCoordinator, @unchecked Sendable {
    var previewLayer: AVCaptureVideoPreviewLayer
    
    init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = .resizeAspectFill
    }
    
    @MainActor
    func attach<T:CameraDisplayTarget>(_ target: T) async throws  {
        if let target = target as? CameraDisplayLayerTarget {
            try await attach(target)
            return
        }
        throw DisplayAttachError.invalidInput
    }
    
    
    @MainActor
    func attach(_ target:CameraDisplayLayerTarget) async throws {
        await target.addSublayer(previewLayer)
        target.previewLayer = previewLayer
    }
}


