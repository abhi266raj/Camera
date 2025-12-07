//
//  CameraOutputService.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//


public protocol CameraOutputService {
    
    associatedtype PreviewService: CameraContentPreviewService
    associatedtype RecordingService: CameraContentRecordingService
    
    var previewService: PreviewService {get}
    var recordingService: RecordingService {get}
}