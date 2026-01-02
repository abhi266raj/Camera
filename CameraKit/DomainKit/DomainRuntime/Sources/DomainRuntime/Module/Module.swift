//
//  Module.swift
//  CameraKit
//
//  Created by Abhiraj on 17/12/25.
//

import DomainApi
import PlatformApi
import CoreMedia

public struct Module {
    let dependecy: Dependency
    
    public init(dependecy: Dependency) {
        self.dependecy = dependecy
    }
    
    public func makeCameraFactory(persistanceService: MediaPersistenceService) -> CameraFactory {
        //let permissionService = makeServiceFactory().makePermissionService()
      //  let storageService = storageServiceFactory(permissionService: permissionService).makeMediaPersistenceService()
        return CameraFactoryImp(platformFactory: dependecy.platformFactoryBuilder, persistanceService: persistanceService)
    }
    
    public func makeServiceFactory() -> ServiceFactory {
        return DomainFactory()
    }
    
    public func storageServiceFactory(permissionService: PermissionService) -> StorageFactory {
        return StorageFactoryImp(mediaPersistenceGateway: dependecy.persistenceGateway, permissionService: permissionService)
    }
}

public typealias  PlatformFactoryBuilder =  () -> PlatformFactory<CMSampleBuffer>
public struct Dependency {
    let platformFactoryBuilder:PlatformFactoryBuilder
    let persistenceGateway: MediaPersistenceGateway
        
    public init(persistenceGateway: MediaPersistenceGateway, platformFactory: PlatformFactory<CMSampleBuffer>) {
        self.platformFactoryBuilder = { platformFactory }
        self.persistenceGateway = persistenceGateway
    }
}
