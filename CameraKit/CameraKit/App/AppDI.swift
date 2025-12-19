// MARK: - SERVICE LAYER

import CoreKit
import DomainApi
import DomainRuntime
import AppViewModel
import AppView
import PlatformApi
import PlatformRuntime



protocol PlatfomOutput {
    var platformFactoy: PlatformFactory {get}
}

protocol DomainOutput {
    var permissionService: PermissionService { get }
    var cameraFactory: CameraFactory {get}
}

protocol ViewModelOutput {
    var cameraViewModelProvider: CameraViewModelProvider {get}
}

protocol CameraViewModelProvider {
    func cameraViewModel(for cameraType: CameraType) async  -> CameraViewModel
    func filterViewModel() async -> any FilterListViewModel
    
}


struct PlatformOutputImpl: PlatfomOutput {
    var platformFactoy: PlatformFactory
}

class DomainOutputImpl: DomainOutput {
    let domainModule: DomainRuntime.Module
    lazy var cameraFactory = domainModule.makeCameraFactory()
    init(domainModule: DomainRuntime.Module) {
        self.domainModule = domainModule
    }
    lazy var permissionService: PermissionService = domainModule.makeServiceFactory().makePermissionService()
}

protocol ViewModelDependcies {
    var filterCoordinator: FilterCoordinator { get }
    var cameraService: CameraEngine {get}
    var permissionService: PermissionService { get }
}

struct CameraDependenciesImpl: ViewModelDependcies {
    
    let coreDependencies:DomainOutput
    let cameraService: CameraEngine
    var filterCoordinator: FilterCoordinator
    var permissionService: PermissionService {
        return coreDependencies.permissionService
    }
}

class CameraViewModelProviderImpl: CameraViewModelProvider {
    
    var dep: DomainOutput
    
    init(dep: DomainOutput) {
        self.dep = dep
    }
    
    lazy var filterCoordinator = factory.makeFilterCoordinator()
    lazy var factory = dep.cameraFactory
    
    func cameraService(for cameraType: CameraType) async -> CameraEngine {
        await MainActor.run {
            let profile = cameraProfile(for: cameraType)
            return factory.makeCameraEngine(profile: profile)
        }
    }

    private func cameraProfile(for type: CameraType) -> CameraProfile {
        switch type {
        case .multicam: return .multiCam
        case .basicPhoto: return .simplephoto
        case .basicVideo: return .video
        case .metal: return .filter
        }
    }

    func cameraViewModel(for cameraType: CameraType) async  -> CameraViewModel {
        let cameraService = await cameraService(for: cameraType)
        return await CameraViewModel(permissionService: dep.permissionService, cameraService: cameraService)
        
    }
    
    func filterViewModel() async -> any FilterListViewModel {
        FilterListViewModelImp(coordinator: filterCoordinator)
        
    }
    
}

// MARK: - APP ROOT CONTAINER

final class AppDependencies {
    static let shared = AppDependencies()

    let platformDependency: PlatfomOutput
    let domainDependency: DomainOutput
    let viewModelProvider: CameraViewModelProvider

    private init() {
        let platformDep = PlatformRuntime.Dependency()
        let platformModule = PlatformRuntime.Module(dependency: platformDep)
        let platformdep = platformModule.makePlatformFactory()
        let platformDepImp = PlatformOutputImpl(platformFactoy: platformdep)
        let dep = DomainRuntime.Dependency(platformFactoryBuilder: {platformDepImp.platformFactoy})
        let module = DomainRuntime.Module(dependecy: dep)
        let domainDependency = DomainOutputImpl(domainModule: module)
        self.domainDependency = domainDependency
        self.platformDependency = platformDepImp
        self.viewModelProvider = CameraViewModelProviderImpl(dep: domainDependency)
    }
}


