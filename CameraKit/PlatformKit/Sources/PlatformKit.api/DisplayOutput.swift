//
//  CameraContentPreviewService.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import UIKit
import CoreKit

public protocol CameraDisplayOutput {
    var previewView: UIView {get}
    func updateFrame()
}


public final class CameraDisplayOutputImp: UIView,@preconcurrency CameraDisplayOutput  {
    public var previewView: UIView = UIView()
    
    public func updateFrame() {
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

public protocol CameraDisplayCoordinator {
    @MainActor
    func attach(_ target: some CameraDisplayTarget) async throws
}



