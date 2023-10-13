//
//  MetalOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 10/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos


class MetalOutput: CameraOutputProtocol {
    
    private var session:AVCaptureSession
    var previewView: UIView
    var metalView: PreviewMetalView
    
    init(session: AVCaptureSession) {
        self.session = session
        metalView = PreviewMetalView(frame: CGRectMake(0, 0, 1080/4, 1920/4))
        //metalView.backgroundColor = .red
        previewView = UIView(frame: CGRectMake(0, 0, 1080/4, 1920/4))
        previewView.addSubview(metalView)
        //previewView.backgroundColor = .green
        metalView.backgroundColor = .yellow
    
        
        
    }
    
    func updateFrame () {
        if previewView.bounds != CGRectZero {
            metalView.frame = previewView.bounds
        }
//        
   }
    
}
