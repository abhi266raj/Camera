//
//  CameraContentRecordingService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Combine
import CoreKit

public protocol CameraContentRecordingService {
    var supportedOutput: CameraAction {get}
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    
}
