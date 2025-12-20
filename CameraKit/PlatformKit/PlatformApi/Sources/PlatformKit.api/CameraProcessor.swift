//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import CoreMedia
import CoreKit

public protocol CameraProccessor: class {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer
    var selectedFilter: (any FilterModel)? {get set}
}

public protocol FilterSelectionDelegate: AnyObject {
    func didUpdateSelection(_ filter: FilterModel?)
}

