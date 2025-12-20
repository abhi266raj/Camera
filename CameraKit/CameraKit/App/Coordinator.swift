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
    //let viewModelServiceProvider: CameraViewDependenciesProvider
    
    let viewModelProvider: CameraViewModelProvider

    init(viewModelProvider: CameraViewModelProvider = AppDependencies.shared.viewModelProvider) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor
    func makeCameraView(cameraType: CameraType = .metal) -> some View {
        let view = AsyncView {
            let cameraViewModel = await self.viewModelProvider.cameraViewModel(for: cameraType)
            let filterVM = await self.viewModelProvider.filterViewModel()
            return CameraView(viewModel: cameraViewModel, filterListViewModel: filterVM)
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
    
    private var componentBuilder: CameraComponentBuilder {
        CameraComponentBuilder()
    }
    var path = NavigationPath()

    init() {
        
    }

    @MainActor
    func createView(cameraType: CameraType = .metal) -> some View {
         componentBuilder.makeCameraView(cameraType: cameraType)
    }
    
    var rootDepedency = HomeViewModelDependency()
    
    @MainActor
    func start() ->  some View {
        let viewModel = rootDepedency.viewModel
        let view = CameraTypeListView(viewData: viewModel.viewData) { cameraType in
            viewModel.trigger(cameraType)
        }
        rootDepedency.selectionCooridator.onSelect = {[weak self] type in
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


