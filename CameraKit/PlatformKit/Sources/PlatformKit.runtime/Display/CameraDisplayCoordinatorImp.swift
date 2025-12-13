//
//  CameraOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine
import PlatformKit_api
import CoreKit


public class CameraLayerDisplayCoordinatorImp: CameraDisplayCoordinator {
    var previewLayer: AVCaptureVideoPreviewLayer
    
    public init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = .resizeAspectFill
    }
    
    @MainActor
    public func attach<T:CameraDisplayTarget>(_ target: T) async throws  {
        if let target = target as? CameraDisplayLayerTarget {
            try await attach(target)
            return
        }
        print("Error")
        throw DisplayAttachError.invalidInput
    }
    
    
    @MainActor
    public func attach(_ target:CameraDisplayLayerTarget) async throws {
        await target.addSublayer(previewLayer)
        target.previewLayer = previewLayer
    }
}

public class CameraMetalDisplayCoordinatorImp: CameraDisplayCoordinator {
    public let metalView: PreviewMetalView
    
    public init(metalView: PreviewMetalView) {
        self.metalView = metalView
    }
    
    @MainActor
    public func attach<T:CameraDisplayTarget>(_ target: T) async throws  {
        if let target = target as? CameraDisplayMetalTarget {
            try await attach(target)
            return
        }
        print("Error")
        throw DisplayAttachError.invalidInput
    }
    
    
    @MainActor
    public func attach(_ target:CameraDisplayMetalTarget) async throws {
        await target.metalView = metalView
    }
}

