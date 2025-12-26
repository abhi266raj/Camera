//
//  CameraMetalDisplayCoordinatorImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//

import Foundation
import AVFoundation
import PlatformApi
import CoreKit
import UIKit

final class CameraMetalDisplayCoordinatorImp: SampleBufferDisplayCoordinator, Sendable {
    
    @MainActor func getBufferProvider() -> ContentProducer? {
        previewMetalView
    }
    
    @MainActor func getBufferReciever() -> ContentReciever? {
        previewMetalView
    }
    
    @MainActor var previewMetalView: PreviewMetalView?
    
    init() {
    }
    
    @MainActor
    func attach<T:CameraDisplayTarget>(_ target: T) async throws  {
        if let target = target as? CameraDisplayMetalTarget {
            try await attach(target)
            return
        }
        print("Error")
        throw DisplayAttachError.invalidInput
    }
    
    
    @MainActor
    func attach(_ target:CameraDisplayMetalTarget) async throws {
        self.previewMetalView = PreviewMetalView(frame: .zero)
        await target.metalView = previewMetalView
    }
}
