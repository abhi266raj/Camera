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

// MARK: - Camera Component (Child)


final class CameraComponentBuilder {

    // Injected service dependencies
    let viewModelServiceProvider: ViewModelDependenciesProvider

    init(viewModelServiceProvider: ViewModelDependenciesProvider = AppDependencies.shared.viewModels) {
        self.viewModelServiceProvider = viewModelServiceProvider
    }

    @MainActor
    func makeCameraView(cameraType: CameraType = .metal) -> some View {
        let view = AsyncView {
            let viewModelDependcies = await self.viewModelServiceProvider.viewModels(for: cameraType)
            let vm = viewModelDependcies.cameraViewModel
            let filterVM = viewModelDependcies.filterListViewModel
            return CameraView(viewModel: vm, filterListViewModel: filterVM)
        }
        return view
    }
}

struct AsyncView<Content: View>: View {
    @State private var content: Content?
    let loader: () async -> Content

    @ViewBuilder
    var body: some View {
            if let content = content {
                content
            } else {
                Text("Loading...").task {
                    content = await loader()
                }
            }
        
    }
}

@Observable
class AppCoordinator {
    
    private let componentBuilder: CameraComponentBuilder
    var path = NavigationPath()

    init(componentBuilder: CameraComponentBuilder = CameraComponentBuilder()) {
        self.componentBuilder = componentBuilder
    }

    @MainActor
    func createView(cameraType: CameraType = .metal) -> some View {
         componentBuilder.makeCameraView(cameraType: cameraType)
    }
    
    @MainActor
    func showHomeView() ->  some View {
        let viewModelDep = HomeViewModelDependency()
        let viewModel = viewModelDep.viewModel
        let view = CameraTypeListView(viewData: viewModel.viewData) { cameraType in
            viewModel.trigger(cameraType)
        }
        viewModelDep.selectionCooridator.onSelect = {[weak self] type in
            self?.path.append(type)
        }
        
        return NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            view.navigationDestination(for: CameraType.self) { type in
                self.createView(cameraType: type)
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


