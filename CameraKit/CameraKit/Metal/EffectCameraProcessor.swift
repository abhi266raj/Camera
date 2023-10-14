//
//  FilterProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 14/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos
import CoreMedia


class EffectCameraProcessor : CameraProccessorProtocol {
    
    var filterRender: FilterRenderer = CIFilterRenderer()
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        
        if let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            if filterRender.isPrepared == false {
                if let format = CMSampleBufferGetFormatDescription(sampleBuffer) {
                    filterRender.prepare(with: format, outputRetainedBufferCountHint: 3)
                }else{
                    return sampleBuffer
                }
            }
            if let newPixelBuffer =  filterRender.render(pixelBuffer: videoPixelBuffer)  {
           
                var newSampleBuffer: CMSampleBuffer? = nil
                var timingInfo = CMSampleTimingInfo()
                CMSampleBufferGetSampleTimingInfo(sampleBuffer, at: 0, timingInfoOut: &timingInfo)
                _ = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: newPixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: formatDescription, sampleTiming: &timingInfo, sampleBufferOut: &newSampleBuffer)
                return newSampleBuffer ?? sampleBuffer

               
            }
            
        }
        
        
        return sampleBuffer
    }
    
}

