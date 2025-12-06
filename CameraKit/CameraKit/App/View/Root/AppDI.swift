// MARK: - SERVICE LAYER

protocol CoreDependencies {
    var filterRepository: FilterRepository { get }
    var permissionService: CameraPermissionService { get }
}

class CoreDependenciesImpl: CoreDependencies {
    lazy var filterRepository: FilterRepository = FilterRepositoryImpl()
    lazy var permissionService: CameraPermissionService = CameraPermissionService()
}

protocol CameraDependencies {
    var cameraService: CameraService { get }
    var filterRepository: FilterRepository { get }
    var permissionService: CameraPermissionService { get }
}

struct CameraDependenciesImpl: CameraDependencies {
    
    let coreDependencies:CoreDependencies
    let cameraService: CameraService
    var filterRepository: FilterRepository {
        return coreDependencies.filterRepository
    }
    var permissionService: CameraPermissionService {
        return coreDependencies.permissionService
    }
}

protocol CameraDependenciesProvider {
    func dependencies(for cameraType: CameraType, config: CameraConfig?) -> CameraDependencies
}

final class CameraDependenciesProviderImpl: CameraDependenciesProvider {

    let core:CoreDependencies
    
    init(core:CoreDependencies) {
        self.core = core
    }

    func dependencies(for cameraType: CameraType, config: CameraConfig?) -> CameraDependencies {
        let resolvedConfig = config ?? cameraType.getCameraConfig()

        let cameraService: CameraService = {
            switch cameraType {
            case .camera:
                return CameraPipeline(cameraOutputAction: resolvedConfig.cameraOutputAction)
            case .basicPhoto:
                return BasicPhotoPipeline(cameraOutputAction: resolvedConfig.cameraOutputAction)
            case .basicVideo:
                return BasicVideoPipeline(cameraOutputAction: resolvedConfig.cameraOutputAction)
            case .metal:
                return BasicMetalPipeline(cameraOutputAction: resolvedConfig.cameraOutputAction)
            }
        }()

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
    func viewModels(for cameraType: CameraType) -> ViewModelDependencies
}

struct ViewModelDependenciesProviderImpl: ViewModelDependenciesProvider {
    let services: CameraDependenciesProvider

    func viewModels(for cameraType: CameraType) -> ViewModelDependencies {
        let deps = services.dependencies(for: cameraType, config: nil)

        let cameraVM = CameraViewModel(
            permissionService: deps.permissionService,
            cameraConfig: cameraType.getCameraConfig(),
            cameraService: deps.cameraService
        )

        let filterVM = FilterListViewModel(
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


// MARK: - USAGE EXAMPLE

// let vm = AppDependencies.shared
//            .viewModels
//            .viewModels(for: .camera)
//            .cameraViewModel
