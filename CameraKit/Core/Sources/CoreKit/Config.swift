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


public enum CameraPhase: Equatable, Hashable, Sendable {
    case inactive
    case paused
    case switching
    case active(CameraMode)
}

// Camera operation mode
public enum CameraMode: Sendable, Equatable, Hashable {
    case preview
    case initiatingCapture
    case capture(CaptureType)
}

// Specific capture type
public enum CaptureType: Sendable, Equatable, Hashable {
    case photo
    case video
}

public struct CameraAction: OptionSet, Sendable {
    
    public enum ActionError: Error {
        case invalidInput
        case unsupported
        case operationError(Error)
    }
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let startRecord = CameraAction(rawValue: 1 << 0)
    public static let stopRecord = CameraAction(rawValue: 1 << 1)
    public static let photo = CameraAction(rawValue: 1 << 3)
}

public enum CameraType: CaseIterable, Identifiable, Sendable {
    case basicPhoto
    case basicVideo
    case metal
    case multicam

    public var id: Self { self }
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

