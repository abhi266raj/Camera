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

class CameraMetalDisplayCoordinatorImp: CameraDisplayCoordinator {
    let builder: () -> UIView
    
    init(builder: @escaping () -> UIView) {
        self.builder = builder
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
        let metalView = builder()
        await target.metalView = metalView
    }
}
