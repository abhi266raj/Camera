//
//  Config.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//

// Top-level camera state


public enum CameraProfile: Hashable, Sendable {
       case multiCam
       case simplephoto
       case filter
       case video
}


public enum CameraPhase {
    case inactive
    case paused
    case switching
    case active(CameraMode)
}

// Camera operation mode
public enum CameraMode: Sendable {
    case preview
    case initiatingCapture
    case capture(CaptureType)
}

// Specific capture type
public enum CaptureType: Sendable {
    case photo
    case video
}

public struct CameraAction: OptionSet, Sendable {
    
    public enum ActionError: Error {
        case invalidInput
        case unsupported
    }
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let startRecord = CameraAction(rawValue: 1 << 0)
    public static let stopRecord = CameraAction(rawValue: 1 << 1)
    public static let photo = CameraAction(rawValue: 1 << 3)
}

public enum CameraRenderMode {
    case legacy
    case metal
    case basic
    case mutliCam
    
}

public enum CameraType: CaseIterable, Identifiable, Sendable {
    case basicPhoto
    case basicVideo
    case metal
    case multicam

    public var id: Self { self }
    
   
    private var renderMode: CameraRenderMode {
        switch self {
        case .multicam:
            return .mutliCam
        case .basicPhoto:
            return .basic
        case .basicVideo:
            return .basic
        case .metal:
            return .metal
        }
    }
    
   
    
    private var cameraOutputAction:CameraAction {
        switch self {
        case .multicam:
            []
        case .basicPhoto:
            [.photo]
        case .basicVideo:
            [.startRecord, .stopRecord]
        case .metal:
            [.startRecord, .stopRecord]
        }
    }
}


public extension CameraType {
    var title: String {
        switch self {
        case .multicam: return "Multi-Cam"
        case .basicPhoto: return "Photo Camera"
        case .basicVideo: return "Video Camera"
        case .metal: return "Filtered (Metal) Camera"
        }
    }
}

