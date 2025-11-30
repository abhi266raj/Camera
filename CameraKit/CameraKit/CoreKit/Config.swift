//
//  Config.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//

public struct CameraOutputAction: OptionSet {
    
    enum ActionError: Error {
        case invalidInput
        case unsupported
    }
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let startRecord = CameraOutputAction(rawValue: 1 << 0)
    public static let stopRecord = CameraOutputAction(rawValue: 1 << 1)
    public static let photo = CameraOutputAction(rawValue: 1 << 3)
    public static let normalView = CameraOutputAction(rawValue: 1 << 4)
    public static let filterView = CameraOutputAction(rawValue: 1 << 5)
}

protocol BaseConfig {
    var cameraOutputAction:[CameraOutputAction] {get}
}

struct CameraConfig: BaseConfig {
    let cameraOutputAction: [CameraOutputAction]
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
            return CameraConfig(cameraOutputAction: cameraOutputAction)
        case .basicPhoto:
            return CameraConfig(cameraOutputAction: cameraOutputAction)
        case .basicVideo:
            return CameraConfig(cameraOutputAction: cameraOutputAction)
        case .metal:
            return CameraConfig(cameraOutputAction: cameraOutputAction)
        }
    }
    
    var cameraOutputAction:[CameraOutputAction] {
        switch self {
        case .camera:
            [.normalView]
        case .basicPhoto:
            [.normalView]
        case .basicVideo:
            [.normalView]
        case .metal:
            [.filterView, .startRecord, .stopRecord]
        }
    }
}
