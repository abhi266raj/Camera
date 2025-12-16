//
//  CameraContentPreviewService.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import UIKit
import CoreKit
import CoreMedia


public protocol PreviewMetalTarget: UIView {
     var sampleBuffer: CMSampleBuffer? {get set}
    var renderingDelegate:MetalRenderingDelegate? {get set}
}

public protocol MetalRenderingDelegate: class  {
    func sampleBufferRendered(_ buffer: CMSampleBuffer)
}

public protocol CameraDisplayCoordinator {
    @MainActor
    func attach(_ target: some CameraDisplayTarget) async throws
}



