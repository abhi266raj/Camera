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


public final class CameraPreviewView: UIView, @preconcurrency CameraDisplayOutput, CameraDisplayLayerTarget {
    public var previewLayer: CALayer?
    public let displayCoordinator:CameraLayerDisplayCoordinatorImp
    
    @MainActor
    public func addSublayer(_ layer: CALayer) async {
        self.layer.addSublayer(layer)
    }
    
    public var previewView: UIView {
        return self
    }
    
    public func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public init(session: AVCaptureSession) {
        displayCoordinator = CameraLayerDisplayCoordinatorImp(session: session)
        super.init(frame:.zero)
        self.commonSetup()
    }
    
    public init(displayCoordinator: CameraLayerDisplayCoordinatorImp) {
        self.displayCoordinator = displayCoordinator
        super.init(frame:.zero)
    }
    
    func commonSetup() {
        Task { @MainActor in
            await try? self.displayCoordinator.attach(self)
        }
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

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
