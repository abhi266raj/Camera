//
//  CameraContentPreviewService.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import UIKit


public protocol CameraDisplayOutput {
    var previewView: UIView {get}
    func updateFrame()
}


