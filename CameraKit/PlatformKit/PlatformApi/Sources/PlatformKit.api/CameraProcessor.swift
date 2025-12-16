//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import CoreMedia
import CoreKit

public protocol CameraProccessor {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer
    func updateSelection(filter: (any FilterModel)?)
}

//public extension CameraProccessor {
//    func updateSelection(filter: (any FilterModel)?) {
//    }
//}

