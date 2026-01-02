//
//  Factory.swift
//  DomainApi
//
//  Created by Abhiraj on 16/12/25.
//

import CoreKit

public protocol ServiceFactory {
    func makePermissionService() -> PermissionService
}

public protocol CameraFactory {
    func makeFilterCoordinator() -> any FilterCoordinator
    func makeCameraEngine(profile: CameraProfile) -> CameraEngine
}


public protocol StorageFactory {
    func makeMediaPersistenceService() -> MediaPersistenceService
}



