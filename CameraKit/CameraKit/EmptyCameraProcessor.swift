//
//  EmptyCameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 14/10/23.
//

import Foundation
import CoreMedia


class EmptyCameraProcessor: CameraProccessorProtocol {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        return sampleBuffer
    }
    
    
}
