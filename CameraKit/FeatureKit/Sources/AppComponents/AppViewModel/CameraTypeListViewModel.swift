//
//  CameraTypeListViewModel.swift
//  FeatureKit
//
//  Created by Abhiraj on 08/12/25.
//


import CoreKit
import Observation

public protocol  CameraTypeListViewModel: ActionableViewModel {
    typealias ViewData = [CameraType]
    typealias ViewAction = CameraType
}

public protocol CameraTypeSelectionCoordinator: AnyObject {
    var onSelect: ((CameraType) -> Void)? { get set }
}

@Observable
public class CameraTypeListViewModelImp: CameraTypeListViewModel, CameraTypeSelectionCoordinator {
    public func trigger(_ action: ViewAction) {
            onSelect?(action)
    }
    
    public var viewData: [CoreKit.CameraType] {
        return cameraTypes
    }
    
    public init() {
        self.cameraTypes = CameraType.allCases
    }
    private var cameraTypes: [CameraType]
    
    public var onSelect: ((CameraType) -> Void)?
    
    private func didSelect(camera: CameraType) {
        onSelect?(camera)
    }
    
}
