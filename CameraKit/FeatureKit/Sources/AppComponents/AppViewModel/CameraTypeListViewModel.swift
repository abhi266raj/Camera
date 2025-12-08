//
//  CameraTypeListViewModel.swift
//  FeatureKit
//
//  Created by Abhiraj on 08/12/25.
//


import CoreKit
import Observation

@Observable
public class CameraTypeListViewModel {
    public init() {
        self.cameraTypes = CameraType.allCases
    }
    public var cameraTypes: [CameraType]
    
    public var onSelect: ((CameraType) -> Void)?
    
    public func didSelect(camera: CameraType) {
        onSelect?(camera)
    }
    
}
