//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import CoreMedia
import CoreKit

public protocol CameraProccessor: FilterSelectionDelegate {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer
}

public protocol FilterSelectionDelegate: AnyObject {
    func didUpdateSelection(_ filter: FilterModel?)
}

public final class FilterSelectionDelegateProxy: FilterSelectionDelegate {
    weak public var target: FilterSelectionDelegate?

    public init() {
    }

    public func didUpdateSelection(_ filter: FilterModel?) {
        target?.didUpdateSelection(filter)
    }
}



//public extension CameraProccessor {
//    func updateSelection(filter: (any FilterModel)?) {
//    }
//}

