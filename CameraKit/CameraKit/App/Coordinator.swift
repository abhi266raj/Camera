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
            let view =  CameraView(viewModel: vm, filterListViewModel: filterVM)
            return AnyView(view)
        }
        let view = AsyncView(model: vmodel)
        return view
    }
}

@Observable class AsyncViewModel {
    var content: AnyView?
    init(loadContent: @escaping () async -> AnyView) {
        Task {
            content = await loadContent()
        }
    }
}

struct AsyncView: View {
    
    @State var model: AsyncViewModel
    
    var body: some View {
        model.content ?? AnyView(Text("Loading"))
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


