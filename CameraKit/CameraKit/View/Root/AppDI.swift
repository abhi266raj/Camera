// MARK: - SERVICE LAYER

protocol ServiceDependencies {
    var cameraService: CameraService { get }
    var filterRepository: FilterRepository { get }
    var permissionService: CameraPermissionService { get }
}

struct CameraDependencies: ServiceDependencies {
    let cameraService: CameraService
    let filterRepository: FilterRepository
    let permissionService: CameraPermissionService
}

protocol ServiceDependenciesProvider {
    func dependencies(for cameraType: CameraType, config: CameraConfig?) -> ServiceDependencies
}

final class ServiceDependenciesProviderImpl: ServiceDependenciesProvider {

    private let sharedFilterRepository = FilterRepositoryImpl()
    private let sharedPermissionService = CameraPermissionService()

    func dependencies(for cameraType: CameraType, config: CameraConfig?) -> ServiceDependencies {
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

        return CameraDependencies(
            cameraService: cameraService,
            filterRepository: sharedFilterRepository,
            permissionService: sharedPermissionService
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
    let services: ServiceDependenciesProvider

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

    let services: ServiceDependenciesProvider
    let viewModels: ViewModelDependenciesProvider

    private init() {
        let serviceProvider = ServiceDependenciesProviderImpl()
        self.services = serviceProvider
        self.viewModels = ViewModelDependenciesProviderImpl(services: serviceProvider)
    }
}


// MARK: - USAGE EXAMPLE

// let vm = AppDependencies.shared
//            .viewModels
//            .viewModels(for: .camera)
//            .cameraViewModel
