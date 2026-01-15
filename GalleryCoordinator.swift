//
//  GalleryCoordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 13/01/26.
//

import SwiftUI
import Observation
import AppView
import AppViewModel
import CoreKit
import UseCaseRuntime
import UseCaseApi


struct GalleryCoordinator: View {
    
    
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
}
