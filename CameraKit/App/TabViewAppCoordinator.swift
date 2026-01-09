//
//  AppTab.swift
//  CameraKit
//
//  Created by Abhiraj on 21/12/25.
//


import SwiftUI
import Observation
import AppView
import AppViewModel
import CoreKit
import UseCaseRuntime

enum AppTab: Hashable, Identifiable {
    case camera(CameraType)
    case settings
    case gallery
    
    var id: Self { self }

    var title: String {
        switch self {
        case .camera(let type): return type.title
        case .settings: return "Settings"
        case .gallery: return "Gallery"
        }
    }

    var systemImage: String {
          switch self {
          case .camera(.basicPhoto): return "camera"
          case .camera(.basicVideo): return "video"
          case .camera(.metal): return "camera.aperture"
          case .camera(.multicam): return "camera.viewfinder"
          case .settings: return "gearshape"
          case .gallery: return "photo.on.rectangle"
          }
      }
}

@Observable
final class TabViewAppCoordinator {

    var tabs: [AppTab]
    var selectedTab: AppTab

    //@ObservationIgnored
   // private let viewModelOutput: ViewModelOutput
    
    @ObservationIgnored private lazy  var viewModelOutput: ViewModelOutput = appDependencies.viewModelOutput
    private let rootDepedency = HomeViewModelDependency()
    private let appDependencies: AppDependencies = AppDependencies()

    init(
        tabs: [AppTab]
    ) {
        self.tabs = tabs
        self.selectedTab = tabs.first!
        //self.viewModelOutput = viewModelOutput
    }
    
    init() {
        let tabs = [AppTab.gallery, AppTab.camera(.basicPhoto), AppTab.camera(.metal), AppTab.camera(.basicVideo), AppTab.camera(.multicam)]
        self.selectedTab = tabs.first!
        self.tabs = tabs
    }

    @MainActor
    func start() -> some View {
        TabView(selection: Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 })) {
            ForEach(tabs) { tab in
                self.tabView(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
    }

    @MainActor
   @ViewBuilder
    private func tabView(for tab: AppTab) -> some View {
        switch tab {
        case .camera(let type):
            cameraTab(cameraType: type)

        case .settings:
             settingsTab()
        case .gallery:
             galleryView()
        }
        
    }
    
    var path = NavigationPath()
    @MainActor func galleryView() -> some View {
        let viewModel = GalleryViewModel(galleryLoader: GalleryLoaderImp(), permissionService: appDependencies.domainOutput.permissionService)
        let config = GalleryViewConfig(onLoad: {
            await viewModel.load()
        },onItemLoad: { viewData in
             await viewModel.loadThumbnail(id: viewData.id)
        }, onItemTap: { viewData in
            await viewModel.tappedOnItem(id: viewData.id)
       })
        
        viewModel.showDetail =  { item in
            self.path.append(AnyData(item))
        }
        
         let  viewData = viewModel.listViewData
        let view = GalleryGridView(viewData: viewData, config: config)
        return NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            view.navigationDestination(for: AnyData<GalleryItemViewData>.self) { data in
                GalleryItemView(data:data.item){}
                    .aspectRatio(contentMode: .fit)
            }
        }
//        return NavigationStack {
//            GalleryGridView(viewData: viewData, config: config)
//        }.navigationDestination(for: GalleryItemViewData.self) { item in
//            GalleryItemView(data:item){}
//        }
        
    }
    
    @MainActor
    private func cameraTab(cameraType: CameraType) -> some View {
        let provider = viewModelOutput.createCameraViewProvider(for: cameraType)
        let coordinator = CameraCoordinator(viewModelProvider: provider)

        return NavigationStack {
            coordinator.cameraView
                .navigationTitle(cameraType.title)
        }
    }

    @MainActor
    private func settingsTab() -> some View {
        NavigationStack {
        }
    }
}

class AnyData<T>: NSObject {
    var item: T
    
    init(_ item: T) {
        self.item = item
    }
}
