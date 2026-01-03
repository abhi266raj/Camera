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
    public let dependecy: Dependency
    
    public init(dependecy: Dependency) {
        self.dependecy = dependecy
    }
    
    public func makeCameraFactory(persistanceService: MediaPersistenceService) -> CameraFactory {
        return CameraFactoryImp(platformFactory: dependecy.platformFactoryBuilder, persistanceService: persistanceService)
    }
}

public typealias  PlatformFactoryBuilder =  () -> PlatformFactory<CMSampleBuffer>
public struct Dependency {
    public let platformFactoryBuilder:PlatformFactoryBuilder
    public let persistenceGateway: MediaPersistenceGateway
        
    public init(persistenceGateway: MediaPersistenceGateway, platformFactory: PlatformFactory<CMSampleBuffer>) {
        self.platformFactoryBuilder = { platformFactory }
        self.persistenceGateway = persistenceGateway
    }
}
