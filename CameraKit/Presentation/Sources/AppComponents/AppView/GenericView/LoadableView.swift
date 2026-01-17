//
//  LoadableView.swift
//  CameraKit
//
//  Created by Abhiraj on 13/01/26.
//

import SwiftUI
import AppViewModel

//public typealias LoadableConfig = @Sendable () -> Void

public struct LoadableConfig {
    public let loadContent: () -> Void
    
    public init(loadContent: @escaping () -> Void) {
        self.loadContent = loadContent
    }
}

public struct LoadableView<Content:View, ViewData>: View {
    
    let config: LoadableConfig
    let viewData: Loadable<ViewData>
    let content: Content!
    
    
    public init(viewData: Loadable<ViewData>, config: LoadableConfig, @ViewBuilder content: (ViewData) -> Content) {
        self.viewData = viewData
        self.config = config
        if case .loaded(let viewData) = viewData {
            self.content =  content(viewData)
        }else {
            self.content = nil
        }
    }
    
    @ViewBuilder
    public var body: some View {
        switch viewData {
        case .idle:
            let loader =  config.loadContent
            Text("Idle State")
            LoadingView()
                .task {
                    loader()
                }
        case .loading:
            Text("Loading State")
            LoadingView()
        case .error(_):
            LoadingView()
            Text("Error")
            
        case .loaded(let viewData):
            content
        }
        
    }
}

extension LoadableView: ContentView, ConfigurableView {
    
}

public struct LoadableConfigNew<ViewData> {
    public let loadViewData: () async throws -> ViewData
    
    public init(loadViewData: @escaping ()  async throws -> ViewData) {
        self.loadViewData = loadViewData
    }
}


public struct LoadableViewNew<Content:View, ViewData>: View {
    
    let config: LoadableConfigNew<ViewData>
    @State var viewData: Loadable<ViewData>
    let content: (ViewData) -> Content
    
    
    public init(viewData: State<Loadable<ViewData>>, config: LoadableConfigNew<ViewData>, @ViewBuilder content: @escaping (ViewData) -> Content) {
        self._viewData = viewData
        self.config = config
        self.content = content
    }
    
    @ViewBuilder
    public var body: some View {
        switch viewData {
        case .idle:
            let loader =  config.loadViewData
            LoadingView()
                .task {
                    if let content = try? await loader() {
                        viewData = .loaded(content)
                    }else {
                        viewData = .error(.unknown)
    
                    }
                }
        case .loading:
            LoadingView()
        case .error(_):
            LoadingView()
        case .loaded(let viewData):
            content(viewData)
        }
        
    }
}

extension LoadableViewNew:  ConfigurableView {
    
}



