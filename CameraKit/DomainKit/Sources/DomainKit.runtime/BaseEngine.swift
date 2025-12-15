//
//  CameraEngine.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//


import Foundation
import Observation
import Combine
import CoreKit
import PlatformKit_api
import DomainKit_api

protocol EngineInternal {
    associatedtype EngineSpecs: Specs
    var specs: EngineSpecs {get}
    var subSystem: CameraSubSystem {get}
}

struct EngineSpecsImp: Sendable, Specs {
    public var capabilty: EngineOption.Capabilty
    public var allConfig: [EngineOption.Config]
    public var availableProfile: [CameraProfile:EngineOption.Config]
    
    init(capabilty: EngineOption.Capabilty, allConfig: [EngineOption.Config], availableProfile: [CameraProfile : EngineOption.Config]) {
        self.capabilty = capabilty
        self.allConfig = allConfig
        self.availableProfile = availableProfile
    }
}


struct BaseConfigBuilder {
    
    private let display: EngineOption.Display?
    private let storage: EngineOption.Storage?
    private let inputOutput: Set<EngineOption.IO>?
    
    private init(display: EngineOption.Display? = nil, storage: EngineOption.Storage? = nil, inputOutput: Set<EngineOption.IO>? = nil) {
        self.display = display
        self.storage = storage
        self.inputOutput = inputOutput
    }
    
    init() {
        self.display = nil
        self.storage = nil
        self.inputOutput = nil
    }
    
    private func copy(display:EngineOption.Display? = nil, storage:EngineOption.Storage? = nil, inputOutput:Set<EngineOption.IO>? = nil) -> Self {
        BaseConfigBuilder(display: display ?? self.display, storage: storage ?? self.storage, inputOutput: inputOutput ?? self.inputOutput)
    }
    
    func baseDisplay() -> Self {
        copy(display: .basic)
    }
    
    func multiDisplay() -> Self {
        copy(display: .multicam)
    }
    
    func metalDisplay() -> Self {
        copy(display: .metal)
    }
    
    func photoRecording() -> Self {
        copy(storage: .photo)
    }
    
    func videoRecroding() -> Self {
        copy(storage: .video)
    }
    
    func noRecording() -> Self {
        copy(storage: .unavailable)
    }
    
    func standardIO() -> Self {
        let standardIO:Set<EngineOption.IO> = [.start, .toggle]
        return copy(inputOutput: standardIO)
        
    }
    
    func baseIO() -> Self {
        let standardIO:Set<EngineOption.IO> = [.start]
        return copy(inputOutput: standardIO)
    }
    
    func standardPlusFilter() -> Self {
        let io:Set<EngineOption.IO> = [.start, .toggle, .ciFilter, .metalFilter]
        return copy(inputOutput: io)
    }
    
    func buildConfig() -> EngineOption.Config? {
        guard let display, let storage, let inputOutput else {return nil}
        return EngineOption.Config(display: display, storage: storage, inputOutput: inputOutput)
    }
    
    
}

extension EngineSpecsImp {
    
    static func photoEngineSpecs() -> Self {
       let builder = BaseConfigBuilder()
        let config = builder.baseDisplay().photoRecording().standardIO().buildConfig()!
        let capabilty = config.asCapabilty()
        let profile: [CameraProfile:EngineOption.Config] = [.simplephoto:config]
        return EngineSpecsImp(capabilty: capabilty, allConfig: [config], availableProfile: profile)
    }
    
    static func multiCamEngineSpecs() -> Self {
       let builder = BaseConfigBuilder()
        let config = builder.multiDisplay().noRecording().baseIO().buildConfig()!
        let capabilty = config.asCapabilty()
        let profile: [CameraProfile:EngineOption.Config] = [.simplephoto:config]
        return EngineSpecsImp(capabilty: capabilty, allConfig: [config], availableProfile: profile)
    }
    
    static func filterCamEngineSpecs() -> Self {
       let builder = BaseConfigBuilder()
        let config = builder.metalDisplay().videoRecroding().standardPlusFilter().buildConfig()!
        let capabilty = config.asCapabilty()
        let profile: [CameraProfile:EngineOption.Config] = [.simplephoto:config]
        return EngineSpecsImp(capabilty: capabilty, allConfig: [config], availableProfile: profile)
    }
    
    static func videoCamEngineSpecs() -> Self {
       let builder = BaseConfigBuilder()
        let config = builder.baseDisplay().videoRecroding().standardIO().buildConfig()!
        let capabilty = config.asCapabilty()
        let profile: [CameraProfile:EngineOption.Config] = [.simplephoto:config]
        return EngineSpecsImp(capabilty: capabilty, allConfig: [config], availableProfile: profile)
    }
}

extension EngineOption.Config {
    
    func asCapabilty() -> EngineOption.Capabilty {
        return EngineOption.Capabilty(display: Set(arrayLiteral: display), storage: Set(arrayLiteral: storage), inputOutput: inputOutput)
    }
}




public class BaseEngine: EngineInternal, CameraEngine {
    public func perform(_ action: EngineAction) async throws {
        switch action {
        case .setup:
            await try subSystem.setup()
        case .toggle:
            await try subSystem.toggleCamera()
        case .updateFilter(let filter):
            await try subSystem.updateSelection(filter: filter)
        case .takePicture:
            await try subSystem.performAction(action: .photo)
        case .startRecording:
            await try subSystem.performAction(action: .startRecord)
        case .stopRecording:
            await try subSystem.performAction(action: .stopRecord)
        }
    }
    
    
    let specs: EngineSpecsImp
    public let activeConfig: EngineOption.Config
    let subSystem: CameraSubSystem
        
    @MainActor
    public init (profile: CameraProfile) {
        switch profile {
        case .simplephoto:
            let specification = EngineSpecsImp.photoEngineSpecs()
            self.activeConfig = specification.allConfig[0]
            self.specs = specification
            self.subSystem = BasicPhotoPipeline()
        case .multiCam:
            let specification = EngineSpecsImp.multiCamEngineSpecs()
            self.activeConfig = specification.allConfig[0]
            self.specs = specification
            self.subSystem = MultiCamPipeline()
        case .video:
            let specification = EngineSpecsImp.videoCamEngineSpecs()
            self.activeConfig = specification.allConfig[0]
            self.specs = specification
            self.subSystem = BasicVideoPipeline(cameraOutputAction: .photo)
            
            
        case .filter:
            let specification = EngineSpecsImp.filterCamEngineSpecs()
            self.activeConfig = specification.allConfig[0]
            self.specs = specification
            self.subSystem = BasicMetalPipeline(cameraOutputAction: .photo)
        }
    }
}



extension BaseEngine {

    
    public var cameraModePublisher: CurrentValueSubject<CoreKit.CameraMode, Never> {
        return subSystem.cameraModePublisher
    }
        
    @MainActor
    public func attachDisplay(_ target: some CoreKit.CameraDisplayTarget) throws {
        try subSystem.attachDisplay(target)
    }
    
}


