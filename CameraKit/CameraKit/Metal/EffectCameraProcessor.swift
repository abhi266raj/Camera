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


class EffectCameraProcessor : CameraProccessor {
    
    var filterRender1: FilterRenderer = CIFilterRenderer()
    var filterRender2: FilterRenderer = MetalFilterRenderer()
    
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        
        var resultBuffer = process(sampleBuffer: sampleBuffer, filterRender: filterRender1)
        resultBuffer = process(sampleBuffer: resultBuffer, filterRender: filterRender2)
        return resultBuffer
        
    }
    func process(sampleBuffer: CMSampleBuffer, filterRender: FilterRenderer) -> CMSampleBuffer {
        
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

