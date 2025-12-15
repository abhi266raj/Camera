// MARK: - SERVICE LAYER

import CoreKit
import DomainKit_api
import DomainKit_runtime
import AppViewModel
import AppView

protocol CoreDependencies {
    var filterRepository: FilterRepository { get }
    var permissionService: CameraPermissionService { get }
}

class CoreDependenciesImpl: CoreDependencies {
    lazy var filterRepository: FilterRepository = FilterRepositoryImpl()
    lazy var permissionService: CameraPermissionService = CameraPermissionService()
}

protocol CameraDependencies {
    var cameraService: CameraEngine { get }
    var filterRepository: FilterRepository { get }
    var permissionService: CameraPermissionService { get }
}

struct CameraDependenciesImpl: CameraDependencies {
    
    let coreDependencies:CoreDependencies
    let cameraService: CameraEngine
    var filterRepository: FilterRepository {
        return coreDependencies.filterRepository
    }
    var permissionService: CameraPermissionService {
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
        
        let cameraService: CameraEngine = await MainActor.run {
            switch cameraType {
            case .multicam:
                return BaseEngine(profile: .multiCam)
            case .basicPhoto:
                return  BaseEngine(profile: .simplephoto)
            case .basicVideo:
                return  BaseEngine(profile: .video)
            case .metal:
                return BaseEngine(profile: .filter)
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


