//
//  AppDI.swift
//  CameraKit
//
//  Created by Abhiraj on 03/12/25.
//


// MARK: - Service Dependency Protocol

protocol ServiceDependencies {
    var filterRepository: FilterRepository { get }
    var cameraServiceBuilder: CameraServiceBuilder { get }
}

final class ServiceComponent: ServiceDependencies {
    lazy var filterRepository: FilterRepository = FilterRepositoryImpl()
    lazy var cameraServiceBuilder: CameraServiceBuilder = CameraServiceBuilder()
}


// MARK: - Root Dependencies

final class AppDependencies {

    static let shared = AppDependencies()
    private init() {}
    lazy var services: ServiceDependencies = ServiceComponent()
}
