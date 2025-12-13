//
//  MetalOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 10/10/23.
//

import Foundation
import UIKit
import PlatformKit_api
import CoreKit

//public final class MetalCameraPreviewView: UIView, CameraDisplayMetalTarget,  @preconcurrency CameraDisplayOutput {
//    public var metalView: UIView? {
//        didSet {
//            guard let metalView else {return}
//            metalView.translatesAutoresizingMaskIntoConstraints = false
//            addSubview(metalView)
//            NSLayoutConstraint.activate([
//                metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
//                metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
//                metalView.bottomAnchor.constraint(equalTo: bottomAnchor),
//                metalView.topAnchor.constraint(equalTo: topAnchor),
//            ])
//        }
//    }
//    
//    public var previewView: UIView {
//        return self
//    }
//    
//    public func updateFrame() {
//        setNeedsLayout()
//        setNeedsDisplay()
//    }
//    
//    //public let metalView: PreviewMetalView
//
//    public init(metalView: PreviewMetalView) {
//        self.metalView = metalView
//        super.init(frame: .zero)
//    }
//
//    required init?(coder: NSCoder) {
//        return nil
//    }
//
//    override public func layoutSubviews() {
//        super.layoutSubviews()
//        metalView?.frame = bounds
//    }
//}
//
//
//
//
//
