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
        let vmodel = AsyncViewModel{
            let viewModelDependcies = await self.viewModelServiceProvider.viewModels(for: cameraType)
            let vm = viewModelDependcies.cameraViewModel
            let filterVM = viewModelDependcies.filterListViewModel
            return CameraView(viewModel: vm, filterListViewModel: filterVM)
        }
        let view = AsyncView(model: vmodel)
        return view
    }
}

@Observable class AsyncViewModel<T: View> {
    var content: T?
    init(loadContent: @escaping () async -> T) {
        Task {
            content = await loadContent()
        }
    }
}

struct AsyncView<T: View>: View {
    
    @State var model: AsyncViewModel<T>
    
    @ViewBuilder
    var body: some View {
            if let content = model.content {
                 content
            }else {
                Text("Loading")
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
        let viewModel = CameraTypeListViewModel()
        let view = CameraTypeListView(viewModel: viewModel)
        viewModel.onSelect = {type in
            self.path.append(type)
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


