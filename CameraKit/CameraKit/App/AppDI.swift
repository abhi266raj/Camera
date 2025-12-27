// MARK: - SERVICE LAYER

import CoreKit
import DomainApi
import DomainRuntime
import AppViewModel
import AppView
import PlatformApi
import PlatformRuntime
import CoreMedia



// Should be more as project grows
class PlatformOutput {
    var platformFactoy: any PlatformFactory<CMSampleBuffer>
    
    init(platformFactoy: any PlatformFactory<CMSampleBuffer>) {
        self.platformFactoy = platformFactoy
    }
}

class DomainOutput {
    private let domainModule: DomainRuntime.Module
    func cameraFactory() -> CameraFactory {
        domainModule.makeCameraFactory()
    }
    init(domainModule: DomainRuntime.Module) {
        self.domainModule = domainModule
    }
    lazy var permissionService: PermissionService = domainModule.makeServiceFactory().makePermissionService()
}

class ViewModelOutput {
    
    private var dep: DomainOutput
    
    init(dep: DomainOutput) {
        self.dep = dep
    }
    
    private func cameraService(for cameraType: CameraType, factory: CameraFactory) -> CameraEngine {
            let profile = cameraProfile(for: cameraType)
            return factory.makeCameraEngine(profile: profile)
    }

    private func cameraProfile(for type: CameraType) -> CameraProfile {
        switch type {
        case .multicam: return .multiCam
        case .basicPhoto: return .simplephoto
        case .basicVideo: return .video
        case .metal: return .filter
        }
    }
    
    
    // Depedency root should only know there are differnt service of differnt camera type
    func createCameraViewProvider(for cameraType: CameraType) -> CameraViewModelFactory {
        let factory = dep.cameraFactory()
        let engine = cameraService(for: cameraType, factory: factory)
        let filterCoordinator = factory.makeFilterCoordinator()
        return CameraViewModelFactory(permissionService: dep.permissionService, cameraEngine: engine, filterCoordinator: filterCoordinator)
    }
}



// MARK: - APP ROOT CONTAINER

final class AppDependencies {
   
    let platformDependency: PlatformOutput
    let domainOutput: DomainOutput
    let viewModelOutput: ViewModelOutput


    init() {
        let platformDep = PlatformRuntime.Dependency()
        let platformModule = PlatformRuntime.Module(dependency: platformDep)
        let platformdep = platformModule.makePlatformFactory()
        let platformDepImp = PlatformOutput(platformFactoy: platformdep)
        let dep = DomainRuntime.Dependency(platformFactoryBuilder: {platformDepImp.platformFactoy})
        let module = DomainRuntime.Module(dependecy: dep)
        let domainDependency = DomainOutput(domainModule: module)
        self.domainOutput = domainDependency
        self.platformDependency = platformDepImp
        self.viewModelOutput = ViewModelOutput(dep: domainOutput)
    }
}


