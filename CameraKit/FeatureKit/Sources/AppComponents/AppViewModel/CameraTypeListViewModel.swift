//
//  CameraTypeListViewModel.swift
//  FeatureKit
//
//  Created by Abhiraj on 08/12/25.
//


import CoreKit
import Observation

public protocol CameraTypeListViewModel: Observable {
    var cameraTypes: [CameraType] { get }
    func didSelect(camera: CameraType)
}

public protocol CameraTypeSelectionCoordinator: AnyObject {
    var onSelect: ((CameraType) -> Void)? { get set }
}

@Observable
public class CameraTypeListViewModelImp: CameraTypeListViewModel, CameraTypeSelectionCoordinator {
    public init() {
        self.cameraTypes = CameraType.allCases
    }
    public var cameraTypes: [CameraType]
    
    public var onSelect: ((CameraType) -> Void)?
    
    public func didSelect(camera: CameraType) {
        onSelect?(camera)
    }
    
}
