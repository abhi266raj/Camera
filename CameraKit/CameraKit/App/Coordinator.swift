//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//
import CoreKit
import AppView
import SwiftUI
import Observation
import AppViewModel
import AppView

@Observable
class AppCoordinator {
    
    var path = NavigationPath()
    @ObservationIgnored private lazy  var viewModelOutput: ViewModelOutput = appDependencies.viewModelOutput
    private let rootDepedency = HomeViewModelDependency()
    private let appDependencies: AppDependencies = AppDependencies()

    init() {
        
    }
    
    @MainActor
    func start() ->  some View {
        let viewModel = rootDepedency.viewModel
        let view = CameraTypeListView(viewData: viewModel.viewData) { cameraType in
            viewModel.trigger(cameraType)
        }
        rootDepedency.selectionCooridator.onSelect = {[weak self] type in
            guard let self else  {return}
            let viewModelProvider = viewModelOutput.createCameraViewProvider(for: type)
            let coordinator = CameraCoordinator(viewModelProvider: viewModelProvider)
            self.path.append(coordinator)
        }
        
        return NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            view.navigationDestination(for: CameraCoordinator.self) { coordinator in
                coordinator.cameraView
        }
        .navigationTitle("Camera Types")
        
        }
    }
}

struct HomeViewModelDependency {
    var viewModel: any CameraTypeListViewModel {
        return cameraViewModel
    }
    
    var selectionCooridator: any CameraTypeSelectionCoordinator {
        return cameraViewModel
    }
  
    private var cameraViewModel: CameraTypeListViewModelImp =  CameraTypeListViewModelImp()
}


