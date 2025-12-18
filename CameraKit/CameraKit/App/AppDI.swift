// MARK: - SERVICE LAYER

import CoreKit
import DomainApi
import DomainRuntime
import AppViewModel
import AppView
import PlatformApi
import PlatformRuntime



protocol PlatfomDependency {
    var platformFactoy: PlatformFactory {get}
}

protocol DomainDependency {
    var permissionService: PermissionService { get }
    var cameraFactory: CameraFactory {get}
}

struct PlatformDependencyImpl: PlatfomDependency {
    var platformFactoy: PlatformFactory
}

class DomainDependencyImpl: DomainDependency {
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
    
    let coreDependencies:DomainDependency
    let cameraService: CameraEngine
    var filterCoordinator: FilterCoordinator
    var permissionService: PermissionService {
        return coreDependencies.permissionService
    }
}

protocol ViewModelDependenciesProvider {
    func dependencies(for cameraType: CameraType) async -> ViewModelDependcies
}

final class ViewModelDependenciesProviderImpl: ViewModelDependenciesProvider {

    let dependecy:DomainDependency
    
    init(dependecy:DomainDependency) {
        self.dependecy = dependecy
    }
    
    func dependencies(for cameraType: CameraType) async -> ViewModelDependcies {
        let factory = dependecy.cameraFactory
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
            coreDependencies: dependecy, cameraService: cameraService, filterCoordinator: coordinator
        )
    }
}

// MARK: - VIEWMODEL LAYER

protocol CameraViewDependencies {
    var cameraViewModel: CameraViewModel { get }
    var filterListViewModel: FilterListViewModel { get }
}

struct ViewModelDependenciesImpl: CameraViewDependencies {
    let cameraViewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel
}

protocol CameraViewDependenciesProvider {
    func viewModels(for cameraType: CameraType) async  -> CameraViewDependencies
}

struct CameraViewDependenciesProviderImpl: CameraViewDependenciesProvider {
    let services: ViewModelDependenciesProvider
    
    

    func viewModels(for cameraType: CameraType) async -> CameraViewDependencies {
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

    let platformDependency: PlatfomDependency
    let domainDependency: DomainDependency
    let services: ViewModelDependenciesProvider
   let viewModels: CameraViewDependenciesProvider

    private init() {
        let platformDep = PlatformRuntime.Dependency()
        let platformModule = PlatformRuntime.Module(dependency: platformDep)
        let platformdep = platformModule.makePlatformFactory()
        let platformDepImp = PlatformDependencyImpl(platformFactoy: platformdep)
        let dep = DomainRuntime.Dependency(platformFactoryBuilder: {platformDepImp.platformFactoy})
        let module = DomainRuntime.Module(dependecy: dep)
        let domainDependency = DomainDependencyImpl(domainModule: module)
        self.domainDependency = domainDependency
        let serviceProvider = ViewModelDependenciesProviderImpl(dependecy:domainDependency)
        self.services = serviceProvider
        self.viewModels = CameraViewDependenciesProviderImpl(services: serviceProvider)
        self.platformDependency = platformDepImp
    }
}


