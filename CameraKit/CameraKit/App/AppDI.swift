// MARK: - SERVICE LAYER

import CoreKit
import DomainApi
import DomainRuntime
import AppViewModel
import AppView
import PlatformApi
import PlatformRuntime



protocol PlatfomDependency {
    var platformFactory: PlatformFactory {get}
}

protocol DomainDependency {
    var permissionService: PermissionService { get }
    var domainModule: DomainRuntime.Module {get}
}

class DomainDependencyImpl: DomainDependency {
    let domainModule: DomainRuntime.Module
    init(domainModule: DomainRuntime.Module) {
        self.domainModule = domainModule
    }
    lazy var permissionService: PermissionService = domainModule.makeServiceFactory().makePermissionService()
}

protocol CameraDependencies {
    var filterCoordinator: FilterCoordinator { get }
    var cameraService: CameraEngine {get}
    var permissionService: PermissionService { get }
}

struct CameraDependenciesImpl: CameraDependencies {
    
    let coreDependencies:DomainDependency
    let cameraService: CameraEngine
    var filterCoordinator: FilterCoordinator
    var permissionService: PermissionService {
        return coreDependencies.permissionService
    }
}

protocol CameraDependenciesProvider {
    func dependencies(for cameraType: CameraType) async -> CameraDependencies
}

final class CameraDependenciesProviderImpl: CameraDependenciesProvider {

    let core:DomainDependency
    
    init(core:DomainDependency) {
        self.core = core
    }
    
    func dependencies(for cameraType: CameraType) async -> CameraDependencies {
        let factory = core.domainModule.makeCameraFactory(cameraType: cameraType)
        let cameraService: CameraEngine =  await MainActor.run {
            switch cameraType {
            case .multicam:
                return factory.makeCameraEngine(profile: .multiCam)
            case .basicPhoto:
                return factory.makeCameraEngine(profile: .simplephoto)
                //BaseEngine(profile: .simplephoto, platfomFactory: plattformFactory)
            case .basicVideo:
                return factory.makeCameraEngine(profile: .video)
                //BaseEngine(profile: .video, platfomFactory: plattformFactory)
            case .metal:
                return factory.makeCameraEngine(profile: .filter)
                //BaseEngine(profile: .filter, platfomFactory: plattformFactory)
            }
        }
        
        let coordinator = factory.makeFilterCoordinator()

        return CameraDependenciesImpl(
            coreDependencies: core, cameraService: cameraService, filterCoordinator: coordinator
        )
    }
}

// MARK: - VIEWMODEL LAYER

protocol ViewModelDependencies {
    var cameraViewModel: CameraViewModel { get }
    var filterListViewModel: FilterListViewModel { get }
}

struct ViewModelDependenciesImpl: ViewModelDependencies {
    let cameraViewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel
}

protocol ViewModelDependenciesProvider {
    func viewModels(for cameraType: CameraType) async  -> ViewModelDependencies
}

struct ViewModelDependenciesProviderImpl: ViewModelDependenciesProvider {
    let services: CameraDependenciesProvider

    func viewModels(for cameraType: CameraType) async -> ViewModelDependencies {
        let deps = await services.dependencies(for: cameraType)

        let cameraVM = CameraViewModel(
            permissionService: deps.permissionService,
            cameraService: deps.cameraService
        )

        let filterVM = FilterListViewModelImp(
            coordinator: deps.filterCoordinator
        )

        return ViewModelDependenciesImpl(
            cameraViewModel: cameraVM,
            filterListViewModel: filterVM
        )
    }
}

// MARK: - APP ROOT CONTAINER

final class AppDependencies {
    static let shared = AppDependencies()

    let core: DomainDependency
    let services: CameraDependenciesProvider
    let viewModels: ViewModelDependenciesProvider

    private init() {
        let platformBuilder = {PlatformFactoryImp()}
        let dep = DomainRuntime.Dependency(platformFactoryBuilder: platformBuilder)
        let module = DomainRuntime.Module(dependecy: dep)
        let core = DomainDependencyImpl(domainModule: module)
        self.core = core
        let serviceProvider = CameraDependenciesProviderImpl(core:core)
        self.services = serviceProvider
        self.viewModels = ViewModelDependenciesProviderImpl(services: serviceProvider)
    }
}


