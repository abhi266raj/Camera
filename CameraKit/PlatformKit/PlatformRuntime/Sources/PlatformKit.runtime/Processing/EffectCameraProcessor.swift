//
//  FilterProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 14/10/23.
//

import CoreMedia
import CoreKit
import PlatformApi

class EffectCameraProcessor: CameraProccessor{
    // typealias Content = CMSampleBuffer
    func createConnection(producer: any PlatformApi.ContentProducer<CMSampleBuffer>, reciever: (any PlatformApi.ContentReciever<CMSampleBuffer>)?) {
        producer.contentProduced = { [weak self] sampleBuffer in
            guard let self, let reciever = reciever else {return}
            let value = process(sampleBuffer: sampleBuffer)
            reciever.contentOutput(reciever, didOutput: value, from: self)
        }
        
    }
    
    // typealias ConnectionType = CMSampleBuffer
    
    var contentProduced: ((CMSampleBuffer) -> Void)?
    
    func contentOutput(_ output: any ContentReciever, didOutput sampleBuffer: CMSampleBuffer, from connection: any ContentConnection) {
        if let contentProduced {
            let value = process(sampleBuffer: sampleBuffer)
            contentProduced(sampleBuffer)
        }
    }
    
    
    var filterRender1: CIFilterRenderer = CIFilterRenderer()
    var filterRender2: MetalFilterRenderer = MetalFilterRenderer()
    
    public init() {
        
    }
    
//    public func setup(connection: ContentConnection) {
//        connection.input.contentProduced = { [weak self] sampleBuffer in
//            guard let self, let output = connection.output else {return}
//            let value = process(sampleBuffer: sampleBuffer)
//            output.contentOutput(output, didOutput: value, from: connection)
//        }
//    }
    
    public func setUpConnection<Producer: ContentProducer, Consumer:ContentReciever>(_ producer: Producer, reciever: Consumer?) where Producer.Content == CMSampleBuffer, Consumer.Content == CMSampleBuffer{
        producer.contentProduced = { [weak self] sampleBuffer in
            guard let self, let reciever = reciever else {return}
            let value = process(sampleBuffer: sampleBuffer)
            reciever.contentOutput(reciever, didOutput: value, from: self)
        }
    }
    
    var selectedFilter: (any FilterModel)? {
        didSet {
            guard let selectedFilter else {return}
            if let selectedFilter =  selectedFilter as? CIFilterModel {
                //filterRender1.reset()
                filterRender1.cifilter = selectedFilter.contents
            }
            
            if let selectedFilter = selectedFilter as? MetalFilterModel {
                filterRender2.createKernel(filter: selectedFilter.contents)
                
            }
        }
    }
    
    public func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer {
        guard let selectedFilter else  {return sampleBuffer }
        var resultBuffer = sampleBuffer
        if selectedFilter.type.contains(.ciFilter) {
            resultBuffer = process(sampleBuffer: sampleBuffer, filterRender: filterRender1)
        }
        if selectedFilter.type.contains(.metalFilter) {
            resultBuffer = process(sampleBuffer: resultBuffer, filterRender: filterRender2)
        }
        
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

