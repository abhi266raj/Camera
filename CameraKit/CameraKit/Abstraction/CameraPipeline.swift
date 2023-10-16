//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation

public protocol CameraPipeline {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineOutput: CameraOutput
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var output: PipelineOutput {get}
    var processor: PipelineProcessor {get}
    
    func setup()
    
    func start(_ record: Bool)
    
}
