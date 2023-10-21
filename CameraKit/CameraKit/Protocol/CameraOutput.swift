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
    
}


enum CameraOutputAction {
    case startRecording
    case stopRecording
    case clickPhoto
}
