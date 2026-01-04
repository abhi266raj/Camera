//
//  CameraViewModelFactory.swift
//  CameraKit
//
//  Created by Abhiraj on 21/12/25.
//

import Foundation
import CoreKit
import DomainApi

final public class CameraViewModelFactory {
    
    private let permissionService: PermissionService
    private let cameraEngine: CameraEngine
    
    
    public init(permissionService: PermissionService, cameraEngine: CameraEngine, filterCoordinator: FilterCoordinator) {
        self.permissionService = permissionService
        self.cameraEngine = cameraEngine
        self.filterCoordinator = filterCoordinator
    }
    
    private let filterCoordinator: FilterCoordinator
 
    @MainActor
    public func cameraViewModel() -> any CameraViewModel {
        return CameraViewModelImp(permissionService: permissionService, cameraService: cameraEngine)
    }
    
    @MainActor
    public func filterViewModel() -> any FilterListViewModel {
        FilterListViewModelImp(coordinator: filterCoordinator)
        
    }
        
}
