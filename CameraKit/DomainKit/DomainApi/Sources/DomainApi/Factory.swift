//
//  Factory.swift
//  DomainApi
//
//  Created by Abhiraj on 16/12/25.
//

import CoreKit

public protocol Factory  {
    
    func makePermissionService() -> PermissionService
    func makeFilterRepository() -> FilterRepository
    
    @MainActor
    func makeCameraEngine(profile: CameraProfile) -> CameraEngine
}
