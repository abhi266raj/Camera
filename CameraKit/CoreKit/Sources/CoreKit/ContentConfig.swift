//
//  ContentConfig.swift
//  CoreKit
//
//  Created by Abhiraj on 12/12/25.
//

public struct ImageCaptureConfig {
    
    public enum PhotoResolution {
        case hd720
        case hd1080
        case vga640
    }
    
    public var resolution:PhotoResolution
    
    
    public init(photoResolution:PhotoResolution = .vga640) {
        self.resolution = photoResolution
    }
    
}


public struct VideoRecordingConfig {
    
    public enum VideoResolution {
        case hd720
        case hd1080
        case vga640
        
//        func getCapturePreset() -> AVCaptureSession.Preset {
//            switch self {
//            case .hd1080:
//                return .hd1920x1080
//            case .hd720:
//                return .hd1280x720
//            case .vga640:
//                return .vga640x480
//            }
//        }
    }
    
    public var resolution:VideoResolution
    
    public init(photoResolution:VideoResolution = .vga640) {
        self.resolution = photoResolution
    }
    
}

