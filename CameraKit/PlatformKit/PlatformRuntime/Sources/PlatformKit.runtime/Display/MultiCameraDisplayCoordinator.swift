//
//  MultiCameraPreviewView.swift
//  PlatformKit
//
//  Created by Abhiraj on 09/12/25.
//

import Foundation
import AVFoundation
import PlatformApi
import CoreKit

class MultiCameraDisplayCoordinator: CameraDisplayCoordinator, @unchecked Sendable {
    
    public let firstLayer: AVCaptureVideoPreviewLayer
    public let secondLayer: AVCaptureVideoPreviewLayer
    public let session: AVCaptureSession
    
    
    init(session: AVCaptureMultiCamSession) {
        self.session = session
        self.firstLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        self.secondLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        firstLayer.videoGravity = .resizeAspectFill
        secondLayer.videoGravity = .resizeAspectFill
    }
    
    @MainActor
    func attach<T:CameraDisplayTarget>(_ target: T) async throws  {
        if let target = target as? DualDisplayLayerTarget {
            try await attach(target)
            return
        }
        print("Error")
        throw DisplayAttachError.invalidInput
    }
    
    @MainActor
    func attach(_ target: DualDisplayLayerTarget) async throws {
        await target.addFirstDisplaylayer(firstLayer)
        await target.addSecondDisplaylayer(secondLayer)
        target.firstDisplayLayer = firstLayer
        target.secondDisplayLayer = secondLayer
    }
    
    
}

