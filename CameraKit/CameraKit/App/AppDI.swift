// MARK: - SERVICE LAYER

import CoreKit
import DomainApi
import DomainRuntime
import AppViewModel
import AppView
import PlatformApi
import PlatformRuntime

protocol CoreDependencies {
    var filterRepository: FilterRepository { get }
    var permissionService: PermissionService { get }
    var factory: DomainApi.Factory {get}
}

class CoreDependenciesImpl: CoreDependencies {
    let factory:Factory
    init(factory: DomainApi.Factory) {
        self.factory = factory
    }
    lazy var filterRepository: FilterRepository = factory.makeFilterRepository()
    //FilterRepositoryImpl()
    lazy var permissionService: PermissionService = factory.makePermissionService()
    //PermissionServiceImp()
}

protocol CameraDependencies {
    var cameraService: CameraEngine { get }
    var filterRepository: FilterRepository { get }
    var permissionService: PermissionService { get }
}

struct CameraDependenciesImpl: CameraDependencies {
    
    let coreDependencies:CoreDependencies
    let cameraService: CameraEngine
    var filterRepository: FilterRepository {
        return coreDependencies.filterRepository
    }
    var permissionService: PermissionService {
        return coreDependencies.permissionService
    }
}

protocol CameraDependenciesProvider {
    func dependencies(for cameraType: CameraType) async -> CameraDependencies
}

final class CameraDependenciesProviderImpl: CameraDependenciesProvider {

    let core:CoreDependencies
    
    init(core:CoreDependencies) {
        self.core = core
    }
    
    func dependencies(for cameraType: CameraType) async -> CameraDependencies {
        
        
        let plattformFactory:PlatformFactory = PlatformFactoryImp()
        let cameraService: CameraEngine =  await MainActor.run {
            switch cameraType {
            case .multicam:
                return core.factory.makeCameraEngine(profile: .multiCam)
            case .basicPhoto:
                return core.factory.makeCameraEngine(profile: .simplephoto)
                //BaseEngine(profile: .simplephoto, platfomFactory: plattformFactory)
            case .basicVideo:
                return core.factory.makeCameraEngine(profile: .video)
                //BaseEngine(profile: .video, platfomFactory: plattformFactory)
            case .metal:
                return core.factory.makeCameraEngine(profile: .filter)
                //BaseEngine(profile: .filter, platfomFactory: plattformFactory)
            }
        }

        return CameraDependenciesImpl(
            coreDependencies: core, cameraService: cameraService
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
            cameraService: deps.cameraService,
            repository: deps.filterRepository
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

    let core: CoreDependencies
    let services: CameraDependenciesProvider
    let viewModels: ViewModelDependenciesProvider

    private init() {
        let core = CoreDependenciesImpl(factory: DomainFactory {PlatformFactoryImp()} )
        self.core = core
        let serviceProvider = CameraDependenciesProviderImpl(core:core)
        self.services = serviceProvider
        self.viewModels = ViewModelDependenciesProviderImpl(services: serviceProvider)
    }
}


