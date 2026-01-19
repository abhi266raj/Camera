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
import AVKit

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
   
    @ObservationIgnored
    @AnyData var path: NavigationPath = NavigationPath()

    
    @MainActor func galleryView() -> some View {
        let neworkService = appDependencies.domainOutput.networkService
        let pexelGalleryLoader = PexelGalleryLoader(networkService: neworkService)
        let contentLoader: GalleryContentLoader = PexelFeedContentLoader()
        let session = PexelGallerySession(feedLoader: pexelGalleryLoader, contentLoader: contentLoader)
        let viewModel = GalleryViewModel(session: session, permissionService: appDependencies.domainOutput.permissionService)
       
        let view =  TestView(viewModel: viewModel)
        
        viewModel.showDetail =  { item in
            if item.isVideo == false {
                self.path.append(AnyData((item.id, item.isVideo)))
            }else {
                Task {
                    do {
                        let url = try await session.videoUrl(id: item.id)
                        self.path.append(url)
                    }catch {
                        self.path.append(AnyData((item.id, item.isVideo)))
                    }
                    
                }
            }
        }
        
        let anyview = AnyView(
            view
            .navigationDestination(for: AnyData<(String, Bool)>.self) { content in
                let item = content.wrappedValue
                let data = GalleryItemViewData(content: .idle, id: item.0, isVideo: item.1)
                let bindable = State(initialValue: data.content)
                let galleryLoadConfig = ContentConfig(width: Int.max, height: Int.max, requiresExactSize: true)
                let config = LoadableConfigNew {
                    if let data = try? await session.loadContent(id: item.0, config: galleryLoadConfig) {
                        return Image(uiImage: data.image)
                    }
                    throw NSError()
                }
                
                LoadableViewNew(viewData:bindable, config: config) { data in
                    let galleryData = GalleryItemViewData(content: .loaded(data), id: item.0, isVideo: item.1)
                    GalleryItemView(data:galleryData){}
                        .aspectRatio(contentMode: .fit)
                }
                
            }.navigationDestination(for: URL.self) { url in
                let player = AVPlayer(url: url)
                VideoPlayer(player: player)
            }
            )
        
        return NavView(view: anyview, path: _path)
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

@Observable
@propertyWrapper
class AnyData<T>: NSObject {
    var wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    init(_ wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: Binding<T> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
}


struct NavView: View {
    
    @AnyData var path: NavigationPath
    var content: AnyView
    
    init(view: AnyView, path: AnyData<NavigationPath>) {
        content = view
        self._path = path
        
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            content
        }
    }
}

struct TestView: View {
    @State var viewModel: GalleryViewModel
   
    let config: LoadableConfig
    let galleryViewConfig: GalleryViewConfig
    
    init(viewModel: GalleryViewModel) {
        let searchAction = ViewAction<String>{ key  in
           await  viewModel.search(key)
        }
        let config = GalleryViewConfig(onLoad: {
            await viewModel.load()
        },onItemLoad: { viewData in
             await viewModel.loadThumbnail(id: viewData.id)
        }, onItemTap: { viewData in
            await viewModel.tappedOnItem(id: viewData.id)
        }, onLoadMore: {
            await viewModel.loadMore()
        }, searchAction: searchAction
        )
        
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
        SearchView(action: galleryViewConfig.searchAction)
        LoadableView(viewData: viewModel.viewData.content, config: config) { viewData in
             GalleryGridView(viewData: viewData, config: galleryViewConfig)
        }.id(viewModel.viewData.id)
    }
}
