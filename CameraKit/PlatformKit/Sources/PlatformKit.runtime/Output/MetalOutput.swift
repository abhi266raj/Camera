//
//  MetalOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 10/10/23.
//

import Foundation
import UIKit
import PlatformKit_api

public final class MetalCameraPreviewView: UIView, @preconcurrency CameraContentPreviewService {
    public var previewView: UIView {
        return self
    }
    
    public func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    let metalView: PreviewMetalView

    init(metalView: PreviewMetalView) {
        self.metalView = metalView
        super.init(frame: .zero)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            metalView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
    }
}





