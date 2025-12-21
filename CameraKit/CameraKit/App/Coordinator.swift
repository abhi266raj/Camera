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


final class CameraCoordinator: Identifiable, Hashable, Equatable {
    
    var id:String = UUID().uuidString
    
    static func == (lhs: CameraCoordinator, rhs: CameraCoordinator) -> Bool {
          lhs.id == rhs.id
      }

      func hash(into hasher: inout Hasher) {
          hasher.combine(id)
    }

    let viewModelProvider: CameraViewModelProvider
    
    @MainActor
    lazy var cameraView: some View = {
        makeCameraView()
    }()

    init(viewModelProvider: CameraViewModelProvider) {
        self.viewModelProvider = viewModelProvider
    }
    
   
    @MainActor
    func makeCameraView() -> some View {
        let view = AsyncView {
            let cameraViewModel = await self.viewModelProvider.cameraViewModel()
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
    
    var path = NavigationPath()
    
    let domainDep: DomainOutput
    var rootDepedency = HomeViewModelDependency()

    init() {
        domainDep = AppDependencies.shared.domainDependency
        
    }
    
    @MainActor
    func start() ->  some View {
        let viewModel = rootDepedency.viewModel
        let view = CameraTypeListView(viewData: viewModel.viewData) { cameraType in
            viewModel.trigger(cameraType)
        }
        rootDepedency.selectionCooridator.onSelect = {[weak self] type in
            guard let self else  {return}
            let viewModelProvider = CameraViewModelProviderImpl(dep: self.domainDep, cameraType: type)
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


