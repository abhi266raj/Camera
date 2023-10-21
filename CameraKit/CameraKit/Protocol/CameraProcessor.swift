//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import CoreMedia

public protocol CameraProccessor {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer
}

