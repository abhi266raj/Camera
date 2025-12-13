//
//  CameraContentPreviewService.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import UIKit
import CoreKit

public protocol CameraDisplayOutput {
    var previewView: UIView {get}
    func updateFrame()
}

public protocol CameraDisplayCoordinator {
    @MainActor
    func attach(_ target: some CameraDisplayTarget) async throws
}



