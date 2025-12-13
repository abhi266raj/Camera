//
//  Config.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//

// Top-level camera state
public enum CameraPhase {
    case inactive
    case paused
    case switching
    case active(CameraMode)
}

// Camera operation mode
public enum CameraMode {
    case preview
    case initiatingCapture
    case capture(CaptureType)
}

// Specific capture type
public enum CaptureType {
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
    case legacyBasic
    case metal
    case basic
    
}

public enum SupportedCameraTask {
    case capturePhoto
    case recordVideo
    case none
}

public protocol BaseConfig {
    var cameraOutputAction:CameraAction {get}
    var renderMode: CameraRenderMode {get}
    var supportedTask: SupportedCameraTask {get}
}

public struct CameraConfig: BaseConfig {
    public let cameraOutputAction: CameraAction
    public let renderMode: CameraRenderMode
    public let supportedTask: SupportedCameraTask
}

public enum CameraType: CaseIterable, Identifiable, Sendable {
    case basicPhoto
    case basicVideo
    case metal
    case multicam

    public var id: Self { self }
    
    public func getCameraConfig() -> CameraConfig {
        switch self {
        case .multicam:
            return CameraConfig(cameraOutputAction: cameraOutputAction, renderMode: renderMode, supportedTask: supportedTask)
        case .basicPhoto:
            return CameraConfig(cameraOutputAction: cameraOutputAction, renderMode: renderMode, supportedTask: supportedTask)
        case .basicVideo:
            return CameraConfig(cameraOutputAction: cameraOutputAction, renderMode: renderMode, supportedTask: supportedTask)
        case .metal:
            return CameraConfig(cameraOutputAction: cameraOutputAction, renderMode: renderMode, supportedTask: supportedTask)
        }
    }
    
    private var renderMode: CameraRenderMode {
        switch self {
        case .multicam:
            return .legacyBasic
        case .basicPhoto:
            return .basic
        case .basicVideo:
            return .legacyBasic
        case .metal:
            return .metal
        }
    }
    
    private var supportedTask: SupportedCameraTask {
        switch self {
        case .multicam:
            return .none
        case .basicPhoto:
            return .capturePhoto
        case .basicVideo:
            return .recordVideo
        case .metal:
            return .recordVideo
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

