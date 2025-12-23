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

enum AppTab: Hashable, Identifiable {
    case camera(CameraType)
    case settings
    case emptyView
    
    var id: Self { self }

    var title: String {
        switch self {
        case .camera(let type): return type.title
        case .settings: return "Settings"
        case .emptyView: return "Empty"
        }
    }

    var systemImage: String {
        switch self {
        case .camera: return "camera"
        case .settings: return "gearshape"
        case .emptyView: return "empty"
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
        let tabs = [AppTab.emptyView, AppTab.camera(.basicPhoto), AppTab.camera(.metal), AppTab.camera(.basicVideo), AppTab.camera(.multicam)]
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
        case .emptyView:
            GalleryGridView()
        }
        
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
