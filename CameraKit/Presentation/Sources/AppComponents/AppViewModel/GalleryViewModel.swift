//
//  GalleryViewModel.swift
//  CameraKit
//
//  Created by Abhiraj on 06/01/26.
//


// MARK: - ViewModel

internal import UIKit
import SwiftUI
import Observation
import UseCaseApi
import DomainApi


public final class GalleryViewModel: Sendable  {
    @MainActor public let viewData: GalleryViewData = GalleryViewData()
    @MainActor public let listViewData: GalleryListViewData = GalleryListViewData()
    private let permissionSerivce: PermissionService
    private let session: GallerySession<GalleryItem>
    
    
    @MainActor
    public var showDetail: ((GalleryItemViewData) -> Void)? = nil
    
    @MainActor
    public init(session: GallerySession<GalleryItem>, permissionService: PermissionService) {
        self.session = session
        self.permissionSerivce = permissionService
    }

    @MainActor
    public func load() async {
        if case .idle = viewData.content {
            let isPermitted = await permissionSerivce.requestGalleryAccess()
            if !isPermitted {
                viewData.content = .error(.permissionDenied)
            } else {
                viewData.content = .loading
                listViewData.hasMore = true
                Task.immediate{
                    await observeFeed()
                }
                await session.loadInitial()
               // viewData.content = .loaded(listViewData)
            }
        }
    }
    
    @MainActor public func loadMore() async {
        await session.loadMore()
    }
    
    private func observeFeed() async  {
            let stream = session.observeFeedStream()
            do {
                for try await content in stream {
                    let viewData = content.map{GalleryItemViewData(id: $0.id)}
                    await updateData(viewData)
                }
            }catch {
                await MainActor.run {
                    if case .loading = viewData.content {
                        viewData.content = .error(.unknown)
                    }
                }
            }
        await MainActor.run(body: {
            listViewData.hasMore = false
        })
    }
    
    @MainActor func updateData(_ data: [GalleryItemViewData]) {
        self.listViewData.items += data
        if case .loading = viewData.content {
            viewData.content = .loaded(listViewData)
        }
    }

    @MainActor
    private func fetchAssets() async {
        listViewData.items = []
       // listViewData.items = await galleryLoader.loadGallery().map{GalleryItemViewData(id: $0.id)}
    }
    
    @MainActor
    public func loadThumbnail(id: String) async  {
        guard case .loaded(let content) = viewData.content else {
            return
        }
        guard let index =  content.items.firstIndex(where: { $0.id == id}) else {
            return
        }
        let item = content.items[index]
        if item.content == .loading  {
            return
        }
        content.items[index] = item.setLoading()
        let image = try? await session.loadContent(id: id).image
        guard let image else {
            content.items[index] = item.setError(.unknown)
            return
        }
        content.items[index] = item.set(image)
    }
    
    @MainActor
    public func tappedOnItem(id: String) async {
        guard let index =  listViewData.items.firstIndex(where: { $0.id == id}) else {
            return
        }
        let data = listViewData.items[index]
        showDetail?(data)
    }
    
    
}

@Observable
@MainActor
public class GalleryViewData: Sendable {
    public var content: Loadable<GalleryListViewData> = .idle
}

@Observable
@MainActor
public class GalleryListViewData: Sendable {
    
    public var count: Int {
        items.count
    }
    
    public var items: [GalleryItemViewData] = []
    public var hasMore: Bool = true
    
}


public struct GalleryItemViewData: Identifiable, Sendable {
    public let id:String
    public let content: Loadable<Image>
    
    public init(image: UIImage? = nil, isLoading: Bool = false, id:String) {
        if let image {
            let image = Image(uiImage: image)
            content = .loaded(image)
        }else {
            if isLoading {
                content = .loading
            }else {
                content = .idle
            }
        }
        
        self.id = id
    }
    
    public init(imageName: String, isLoading: Bool = false, id:String) {
        self.id = id
        let image = Image(systemName: imageName)
        content = .loaded(image)
    }
    
    public init(content: Loadable<Image>, id:String) {
        self.content = content
        self.id = id
    }
    
    public func setLoading() -> Self {
        GalleryItemViewData(content: .loading, id: id)
    }
    
    public func set(_ image: UIImage) -> Self {
        let image = Image(uiImage: image)
        return GalleryItemViewData(content: .loaded(image), id: id)
    }
    
    public func setError(_ error: LoadableError) -> Self {
        GalleryItemViewData(content: .error(error), id: id)
    }
    
    
}


