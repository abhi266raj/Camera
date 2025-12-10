//
//  MultiCameraPreviewView.swift
//  PlatformKit
//
//  Created by Abhiraj on 09/12/25.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine
import PlatformKit_api

public final class MultiCameraPreviewView: UIView, @preconcurrency CameraContentPreviewService {
    
    public var previewView: UIView {
        return self
    }
    
    public func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public let frontPreviewLayer: AVCaptureVideoPreviewLayer
    public let backPreviewLayer: AVCaptureVideoPreviewLayer
    
    private let frontContainerView = UIView()
    private let backContainerView = UIView()
    
    let session: AVCaptureMultiCamSession
    public init(session: AVCaptureMultiCamSession) {
        self.session = session
        self.frontPreviewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        self.backPreviewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        
        super.init(frame: .zero)
        
        frontPreviewLayer.videoGravity = .resizeAspectFill
        backPreviewLayer.videoGravity = .resizeAspectFill
        
        frontContainerView.translatesAutoresizingMaskIntoConstraints = false
        backContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        frontContainerView.layer.addSublayer(frontPreviewLayer)
        backContainerView.layer.addSublayer(backPreviewLayer)
        
        addSubview(frontContainerView)
        addSubview(backContainerView)
        
        NSLayoutConstraint.activate([
            // Front view on top half
            frontContainerView.topAnchor.constraint(equalTo: topAnchor),
            frontContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            
            // Back view on bottom half
            backContainerView.topAnchor.constraint(equalTo: frontContainerView.bottomAnchor),
            backContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        frontPreviewLayer.frame = frontContainerView.bounds
        backPreviewLayer.frame = backContainerView.bounds
    }
}
