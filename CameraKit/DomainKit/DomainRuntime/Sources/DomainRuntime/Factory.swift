//
//  Module.swift
//  DomainRuntime
//
//  Created by Abhiraj on 16/12/25.
//

import DomainApi
import PlatformApi
import CoreKit


public struct CameraFactoryImp: CameraFactory {
    
    //let builder: (() -> PlatformFactory)
    let platformFactory: PlatformFactory
    let filterSelectionDelegateProxy: FilterSelectionDelegateProxy = FilterSelectionDelegateProxy()

    @MainActor
    public func makeCameraEngine(profile: CameraProfile) -> any CameraEngine {
        return BaseEngine(profile: profile, platfomFactory:platformFactory, filterSelectionDelegateProxy: filterSelectionDelegateProxy )
    }
    
    
    public init(platformFactory: @escaping (() -> PlatformFactory)) {
        self.platformFactory = platformFactory()
    }
    
    private func makeFilterRepository() -> any FilterRepository {
        FilterRepositoryImpl()
    }
    
    public func makeFilterCoordinator() -> any FilterCoordinator {
        let repo = makeFilterRepository()
        let result =  FilterCoordinatorImp(repository: repo)
        result.selectionDelgate = filterSelectionDelegateProxy
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
