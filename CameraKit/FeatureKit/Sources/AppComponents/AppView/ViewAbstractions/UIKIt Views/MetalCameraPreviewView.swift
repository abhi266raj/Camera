//
//  MetalCameraPreviewView.swift
//  FeatureKit
//
//  Created by Abhiraj on 14/12/25.
//


import Foundation
import UIKit
import PlatformKit_api
import CoreKit
import SwiftUI
import AppViewModel

struct CameraMetalViewer: UIViewRepresentable {
    private let previewView =  MetalDisplayMetalTargetImp()
    let viewModel: CameraViewModel
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        
    }

    func makeUIView(context: Context) -> UIView {
        viewModel.attachDisplay(previewView)
        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
       
    }
}


final class MetalDisplayMetalTargetImp: UIView, CameraDisplayMetalTarget{
    public var metalView: UIView? {
        didSet {
            guard let metalView else {return}
            metalView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(metalView)
            NSLayoutConstraint.activate([
                metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
                metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
                metalView.bottomAnchor.constraint(equalTo: bottomAnchor),
                metalView.topAnchor.constraint(equalTo: topAnchor),
            ])
        }
    }
    
   

    override public func layoutSubviews() {
        super.layoutSubviews()
        metalView?.frame = bounds
    }
}





