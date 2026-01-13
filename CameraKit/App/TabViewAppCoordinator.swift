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
import UseCaseApi

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

    var homeView: AnyView? = nil
    @MainActor
    func start() -> AnyView {
        if let homeView {
            return homeView
        }
        let tabView = TabView(selection: Binding(
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
        homeView = AnyView(tabView)
        return homeView!
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
    var gview: AnyView?
    

    
    @MainActor func galleryView() -> AnyView {
        if let gview {
            return gview
        }
        let viewModel = GalleryViewModel(galleryLoader: GalleryLoaderImp(), permissionService: appDependencies.domainOutput.permissionService)
       
        let view =  TestView(viewModel: viewModel)
        
        viewModel.showDetail =  { item in
            self.path.append(AnyData(item.id))
        }
        
        let anyview = AnyView(NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            view
                .navigationDestination(for: AnyData<String>.self) { content in
                    let item = content.item
                    let data = GalleryItemViewData(content: .idle, id: item)
                    let bindable = State(initialValue: data.content)
                    let galleryLoadConfig = ContentConfig(width: Int.max, height: Int.max, requiresExactSize: true)
                    let config = LoadableConfigNew {
                        if let data = try? await GalleryLoaderImp().loadContent(id: item, config: galleryLoadConfig) {
                            return Image(uiImage: data.image)
                        }
                        throw NSError()
                    }
                
                    LoadableViewNew(viewData:bindable, config: config) { data in
                        let galleryData = GalleryItemViewData(content: .loaded(data), id: item)
                        GalleryItemView(data:galleryData){}
                            .aspectRatio(contentMode: .fit)
                    }
                    
                }
        }
        )
        self.gview = anyview
        return anyview
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


struct TestView: View {
    let viewModel: GalleryViewModel
   
    let config: LoadableConfig
    let galleryViewConfig: GalleryViewConfig
    
    init(viewModel: GalleryViewModel) {
        let config = GalleryViewConfig(onLoad: {
            await viewModel.load()
        },onItemLoad: { viewData in
             await viewModel.loadThumbnail(id: viewData.id)
        }, onItemTap: { viewData in
            await viewModel.tappedOnItem(id: viewData.id)
       })
        
        let loadableConfig = LoadableConfig {
            Task { @MainActor in
                await viewModel.load()
            }
        }
        self.viewModel = viewModel
        self.config = loadableConfig
        self.galleryViewConfig = config
    }
    
    public var body: some View  {
        LoadableView(viewData: viewModel.viewData.content, config: config) { viewData in
             GalleryGridView(viewData: viewData, config: galleryViewConfig)
        }
    }
}
