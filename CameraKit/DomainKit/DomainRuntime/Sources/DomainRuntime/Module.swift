//
//  Module.swift
//  DomainRuntime
//
//  Created by Abhiraj on 16/12/25.
//

import DomainApi
import PlatformApi
import CoreKit


public struct DomainFactory: Factory {
    
    var builder: (() -> PlatformFactory)
    @MainActor
    public func makeCameraEngine(profile: CameraProfile) -> any CameraEngine {
        let platfomrFactory = builder()
        return BaseEngine(profile: profile, platfomFactory:platfomrFactory )
    }
    
    
    public init(platformFactory: @escaping (() -> PlatformFactory)) {
        self.builder = platformFactory
    }
    
    public func makePermissionService() -> any DomainApi.PermissionService {
        PermissionServiceImp()
    }
    
    public func makeFilterRepository() -> any DomainApi.FilterRepository {
        FilterRepositoryImpl()
    }
}
