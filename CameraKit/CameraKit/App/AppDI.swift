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
}

class CoreDependenciesImpl: CoreDependencies {
    lazy var filterRepository: FilterRepository = FilterRepositoryImpl()
    lazy var permissionService: PermissionService = PermissionServiceImp()
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
                return BaseEngine(profile: .multiCam, platfomFactory: plattformFactory)
            case .basicPhoto:
                return  BaseEngine(profile: .simplephoto, platfomFactory: plattformFactory)
            case .basicVideo:
                return  BaseEngine(profile: .video, platfomFactory: plattformFactory)
            case .metal:
                return BaseEngine(profile: .filter, platfomFactory: plattformFactory)
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
        let core = CoreDependenciesImpl()
        self.core = core
        let serviceProvider = CameraDependenciesProviderImpl(core:core)
        self.services = serviceProvider
        self.viewModels = ViewModelDependenciesProviderImpl(services: serviceProvider)
    }
}


