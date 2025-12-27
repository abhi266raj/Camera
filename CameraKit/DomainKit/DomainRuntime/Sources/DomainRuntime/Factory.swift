//
//  Module.swift
//  DomainRuntime
//
//  Created by Abhiraj on 16/12/25.
//

import DomainApi
import PlatformApi
import CoreKit
import CoreMedia

public final class CameraFactoryImp: CameraFactory {
    
    let platformFactory: PlatformFactory<CMSampleBuffer>
    lazy var modelSelection = platformFactory.makeFilterModelSelection()

    public func makeCameraEngine(profile: CameraProfile) -> any CameraEngine {
        return BaseEngine(profile: profile, platfomFactory:platformFactory, selectionReciever: modelSelection)
    }
    
    
    public init(platformFactory: @escaping (() -> PlatformFactory<CMSampleBuffer>)) {
        self.platformFactory = platformFactory()
    }
    
    private func makeFilterRepository() -> any FilterRepository {
        FilterRepositoryImpl()
    }
    
    public func makeFilterCoordinator() -> any FilterCoordinator {
        let repo = makeFilterRepository()
        let result = FilterCoordinatorImp(repository: repo, sender: modelSelection)
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
        
        
    }
}
