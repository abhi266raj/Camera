//
//  CameraDisplayCoordinatorFactoryImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//
import Foundation
import AVFoundation
import PlatformApi
import CoreKit


public class Module {
    
    let dependency: Dependency
    public init(dependency:Dependency) {
        self.dependency = dependency
    }
    
    public func makePlatformFactory() -> PlatformFactory<CMSampleBuffer> {
        return PlatformFactoryImp()
    }
    
}

public struct Dependency {
    
    public init(){
        
    }
}


