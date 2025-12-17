//
//  Module.swift
//  DomainRuntime
//
//  Created by Abhiraj on 16/12/25.
//

import DomainApi
import PlatformApi
import CoreKit


public struct Module {
    let dependecy: Dependency
    
    public init(dependecy: Dependency) {
        self.dependecy = dependecy
    }
    
    public func makeCameraFactory(profile: CameraProfile) -> CameraFactory {
        return DomainFactory(platformFactory: dependecy.platformFactoryBuilder)
    }
    
    public func makeServiceFactory() -> ServiceFactory {
        return DomainFactory(platformFactory: dependecy.platformFactoryBuilder)
    }
    
    
}
public typealias  PlatformFactoryBuilder =  () -> PlatformFactory
public struct Dependency {
    let platformFactoryBuilder:PlatformFactoryBuilder
    
    public init(platformFactoryBuilder: @escaping PlatformFactoryBuilder) {
        self.platformFactoryBuilder = platformFactoryBuilder
    }
}


public struct DomainFactory: Factory {
    
    //let builder: (() -> PlatformFactory)
    let platformFactory: PlatformFactory
    @MainActor
    public func makeCameraEngine(profile: CameraProfile) -> any CameraEngine {
        return BaseEngine(profile: profile, platfomFactory:platformFactory )
    }
    
    
    public init(platformFactory: @escaping (() -> PlatformFactory)) {
        self.platformFactory = platformFactory()
    }
    
    public func makePermissionService() -> any DomainApi.PermissionService {
        PermissionServiceImp()
    }
    
    private func makeFilterRepository() -> any FilterRepository {
        FilterRepositoryImpl()
    }
    
    public func makeFilterCoordinator() -> any FilterCoordinator {
        let processor = platformFactory.makeEffectProcessor()
        let repo = makeFilterRepository()
        return FilterCoordinatorImp(repository: repo, processor: processor)
    }
}
