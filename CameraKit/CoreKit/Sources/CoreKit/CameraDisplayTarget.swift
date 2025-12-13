//
//  CameraDisplayTarget.swift
//  CoreKit
//
//  Created by Abhiraj on 13/12/25.
//

import UIKit
import Foundation

public protocol CameraDisplayTarget: AnyObject {}


public protocol CameraDisplayLayerTarget: CameraDisplayTarget {
    @MainActor
    var previewLayer:CALayer? {set get}
    @MainActor
    func addSublayer(_ layer: CALayer) async
}


public protocol CameraDisplayMetalTarget: CameraDisplayTarget {
    @MainActor
    func render(frame: CVPixelBuffer) async
}

public protocol CameraDisplayCoordinator {
    @MainActor
    func attach<T: CameraDisplayTarget>(to target: T) async throws
}

public enum DisplayAttachError: Error {
    case invalidInput
}


