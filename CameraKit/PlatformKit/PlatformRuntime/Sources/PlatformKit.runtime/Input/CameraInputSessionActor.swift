//
//  CameraInputManager.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import UIKit

@globalActor
actor CameraInputSessionActor {
    public static let shared =  CameraInputSessionActor()
    static let sharedMyActorsExecutor = CameraUtiltyExecutor()
    nonisolated public var unownedExecutor: UnownedSerialExecutor {
      Self.sharedMyActorsExecutor.asUnownedSerialExecutor()
    }
}

final class CameraUtiltyExecutor: SerialExecutor {
    let serialQueue = DispatchQueue(label: "com.cameraUtiltyExecutor.serialQueue", qos: .utility) // medium priority
    public func enqueue(_ job: UnownedJob) {
        serialQueue.async {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
}
