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

public struct CameraAction: OptionSet {
    
    enum ActionError: Error {
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

enum CameraRenderMode {
    case basic
    case metal
}

enum SupportedCameraTask {
    case capturePhoto
    case recordVideo
    case none
}

protocol BaseConfig {
    var cameraOutputAction:CameraAction {get}
    var renderMode: CameraRenderMode {get}
    var supportedTask: SupportedCameraTask {get}
}

struct CameraConfig: BaseConfig {
    let cameraOutputAction: CameraAction
    let renderMode: CameraRenderMode
    let supportedTask: SupportedCameraTask
}

enum CameraType: CaseIterable, Identifiable {
    case camera
    case basicPhoto
    case basicVideo
    case metal

    var id: Self { self }
    
    func getCameraConfig() -> CameraConfig {
        switch self {
        case .camera:
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
        case .camera:
            return .basic
        case .basicPhoto:
            return .basic
        case .basicVideo:
            return .basic
        case .metal:
            return .metal
        }
    }
    
    private var supportedTask: SupportedCameraTask {
        switch self {
        case .camera:
            return .capturePhoto
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
        case .camera:
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
