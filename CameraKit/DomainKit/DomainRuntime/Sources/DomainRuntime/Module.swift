//
//  Module.swift
//  CameraKit
//
//  Created by Abhiraj on 17/12/25.
//


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
    
    public func makeCameraFactory() -> CameraFactory {
        return CameraFactoryImp(platformFactory: dependecy.platformFactoryBuilder)
    }
    
    public func makeServiceFactory() -> ServiceFactory {
        return DomainFactory()
    }
    
    
}
public typealias  PlatformFactoryBuilder =  () -> PlatformFactory
public struct Dependency {
    let platformFactoryBuilder:PlatformFactoryBuilder
    
    public init(platformFactoryBuilder: @escaping PlatformFactoryBuilder) {
        self.platformFactoryBuilder = platformFactoryBuilder
    }
}
