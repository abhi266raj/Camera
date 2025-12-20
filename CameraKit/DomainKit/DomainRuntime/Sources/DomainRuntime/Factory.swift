//
//  Module.swift
//  DomainRuntime
//
//  Created by Abhiraj on 16/12/25.
//

import DomainApi
import PlatformApi
import CoreKit


public final class CameraFactoryImp: CameraFactory {
    
    let platformFactory: PlatformFactory
    var filterCoordinatorImp: FilterCoordinatorImp?

    @MainActor
    public func makeCameraEngine(profile: CameraProfile) -> any CameraEngine {
        makeFilterCoordinator()
        guard let filterCoordinatorImp else {fatalError()}
        let stream = filterCoordinatorImp.selectionStream
        return BaseEngine(profile: profile, platfomFactory:platformFactory, stream: stream )
    }
    
    
    public init(platformFactory: @escaping (() -> PlatformFactory)) {
        self.platformFactory = platformFactory()
    }
    
    private func makeFilterRepository() -> any FilterRepository {
        FilterRepositoryImpl()
    }
    
    public func makeFilterCoordinator() -> any FilterCoordinator {
        if let filterCoordinatorImp {
            return  filterCoordinatorImp
        }
        let repo = makeFilterRepository()
        let result =  FilterCoordinatorImp(repository: repo)
        self.filterCoordinatorImp = result
        return result
    }
}




public struct DomainFactory: ServiceFactory {
    
    public func makePermissionService() -> any DomainApi.PermissionService {
        PermissionServiceImp()
    }
}


struct CameraEngineBuilder {
    
    let cameraProfile: CameraProfile
    init(cameraType: CameraType) {
        cameraProfile =  {
            switch cameraType {
            case .multicam:
                return .multiCam
            case .basicPhoto:
                return .simplephoto
            case .basicVideo:
                return .video
            case .metal:
                return  .filter
            }
        }()
        
        func build() {
            
        }
        
    }
}
