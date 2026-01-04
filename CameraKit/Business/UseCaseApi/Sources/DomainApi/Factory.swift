//
//  Factory.swift
//  DomainApi
//
//  Created by Abhiraj on 16/12/25.
//

import CoreKit

public protocol CameraFactory {
    func makeFilterCoordinator() -> any FilterCoordinator
    func makeCameraEngine(profile: CameraProfile) -> CameraEngine
}
