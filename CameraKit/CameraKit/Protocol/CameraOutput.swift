//
//  CameraOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import UIKit


public protocol CameraOutput {
    
   
    var previewView: UIView {get}
    func updateFrame()
    
    var supportedOutput: CameraOutputAction {get}
    
    var outputState: CameraOutputState {get}
    
    func performAction( action: CameraOutputAction) async throws -> Bool
    
}

public enum CameraOutputState {
    case unknown
    case rendering
    case switching
    case recording
}



public struct CameraOutputAction: OptionSet {
    
    enum ActionError: Error {
        case invalidInput
        case unsupported
    }
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let startRecord = CameraOutputAction(rawValue: 1 << 0)
    public static let stopRecord = CameraOutputAction(rawValue: 1 << 1)
    public static let photo = CameraOutputAction(rawValue: 1 << 3)
    public static let normalView = CameraOutputAction(rawValue: 1 << 4)
    public static let filterView = CameraOutputAction(rawValue: 1 << 5)
}

