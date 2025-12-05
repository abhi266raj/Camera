//
//  AppDI.swift
//  CameraKit
//
//  Created by Abhiraj on 03/12/25.
//


// MARK: - Service Dependency Protocol

import SwiftUI

protocol ServiceDependencies {
    var filterRepository: FilterRepository { get }
    var cameraService: CameraService { get }
    var permissionService: CameraPermissionService {get}
}

protocol ServiceDependenciesProvider {
    func serviceDependenciesFor(cameraType: CameraType) -> ServiceDependencies
    func serviceDependenciesFor(cameraType: CameraType, cameraConfig: CameraConfig?) -> ServiceDependencies
}

extension ServiceDependenciesProvider {
    func serviceDependenciesFor(cameraType: CameraType) -> ServiceDependencies {
        self.serviceDependenciesFor(cameraType: cameraType, cameraConfig: nil)
    }
}

class ServiceDependenciesProviderImpl: ServiceDependenciesProvider {
    func serviceDependenciesFor(cameraType: CameraType, cameraConfig: CameraConfig?) -> any ServiceDependencies {
        let cameraConfig = cameraConfig ?? cameraType.getCameraConfig()
        return CameraServiceImp(cameraType: cameraType, cameraConfig: cameraConfig)
    }
}

protocol ViewModelDependencies {
    var filterListViewModel: FilterListViewModel {get}
    var cameraViewModel: CameraViewModel {get}
}

protocol ViewModelDependenciesProvider {
    func viewModelDependenciesFor(cameraType: CameraType) -> ViewModelDependencies
}

struct ViewModelServiceImp: ViewModelDependencies{
    
    let filterListViewModel: FilterListViewModel
    let cameraViewModel: CameraViewModel
    
    init(cameraType: CameraType, serviceDependenciesProvider: ServiceDependenciesProvider) {
        let serviceDependencies = serviceDependenciesProvider.serviceDependenciesFor(cameraType: cameraType)
        let cameraService = serviceDependencies.cameraService
        cameraViewModel = CameraViewModel(permissionService:serviceDependencies.permissionService, cameraConfig: cameraType.getCameraConfig(), cameraService: cameraService)
        filterListViewModel = FilterListViewModel(cameraService: cameraService, repository: serviceDependencies.filterRepository)
    }
}

struct ViewModelDependenciesProviderImp: ViewModelDependenciesProvider {
    
    let service: ServiceDependenciesProvider
    
    func viewModelDependenciesFor(cameraType: CameraType) -> ViewModelDependencies {
        ViewModelServiceImp(cameraType: cameraType, serviceDependenciesProvider: service)
    }
}

class CameraServiceImp: ServiceDependencies {
    
    let cameraType: CameraType
    let cameraConfig: CameraConfig
    init(cameraType: CameraType, cameraConfig: CameraConfig) {
        self.cameraType = cameraType
        self.cameraConfig = cameraConfig
    }
    
    
    lazy var cameraService: CameraService =
    {
        switch cameraType {
        case .camera:
            return CameraPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .basicPhoto:
            return BasicPhotoPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .basicVideo:
            return BasicVideoPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .metal:
            return BasicMetalPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        }
    }()
    
    lazy var filterRepository: FilterRepository = FilterRepositoryImpl()
    lazy var permissionService: CameraPermissionService = CameraPermissionService()
}



// MARK: - Root Dependencies

final class AppDependencies {

    static let shared = AppDependencies()
    lazy private(set) var services: ServiceDependenciesProvider = ServiceDependenciesProviderImpl()
    lazy private(set) var viewModelServiceProvider = ViewModelDependenciesProviderImp(service: services)
}
