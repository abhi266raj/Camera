//
//  CameraPreviewView.swift
//  FeatureKit
//
//  Created by Abhiraj on 13/12/25.
//

import UIKit
import CoreKit
import SwiftUI
import AppViewModel

struct CameraFeedViewer: UIViewRepresentable {
    private let previewView =  CameraVideoPreviewView()
    let viewAction: (CameraViewAction) -> Void
    

    func makeUIView(context: Context) -> UIView {
        previewView.backgroundColor = .black
        viewAction(.attachDisplay(previewView))
        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
       
    }
}


private final class CameraVideoPreviewView: UIView, CameraDisplayLayerTarget {
    public var previewLayer: CALayer?
    
    
    @MainActor
    public func addSublayer(_ layer: CALayer) async {
        self.layer.addSublayer(layer)
    }
    
 
    override public func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
