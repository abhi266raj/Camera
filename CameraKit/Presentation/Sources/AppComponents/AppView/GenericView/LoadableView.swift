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
    let content: (ViewData) -> Content
    
    public init(viewData: Loadable<ViewData>, config: LoadableConfig, @ViewBuilder content: @escaping (ViewData) -> Content) {
        self.viewData = viewData
        self.config = config
        self.content = content
    }
    
    @ViewBuilder
    public var body: some View {
        switch viewData {
        case .idle:
            let loader =  config.loadContent
            LoadingView()
                .task {
                    loader()
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

extension LoadableView: ContentView, ConfigurableView {
    
}

