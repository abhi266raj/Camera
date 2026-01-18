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
internal import OSLog


public final class GalleryViewModel: Sendable  {
    @MainActor public let viewData: GalleryViewData = GalleryViewData()
    @MainActor private var listViewData: GalleryListViewData = GalleryListViewData()
    
    @MainActor var needRestart: Bool = false
    @MainActor var isObserving: Bool = false
    private let permissionSerivce: PermissionService
    private let session: GallerySession<GalleryItem>
    private let logger = Logger(subsystem: "Gallery", category: "ViewModel")
    
    @MainActor
    public var showDetail: ((GalleryItemViewData) -> Void)? = nil
    
    @MainActor
    private var shouldRestart: Bool = false
    
    @MainActor
    public init(session: GallerySession<GalleryItem>, permissionService: PermissionService) {
        self.session = session
        self.permissionSerivce = permissionService
    }

    @MainActor
    public func load() async {
        logger.log("Can Started load feed \(self.viewData.id)")
        if case .idle = viewData.content {
            logger.log("Started load feed")
            await initialLoad()
        }else {
            logger.log("Not started load \(self.viewData.id)")
        }
    }
    
    @MainActor
    private func initialLoad() async {
        await session.reset()
        viewData.content = .loading
        listViewData.hasMore = true
        isObserving = true
        Task.immediate{
            await observeFeed(stream: nil)
        }
        await Task.yield()
        await session.loadInitial()
        
    }
    
    @MainActor public func loadMore() async {
        await session.loadMore()
    }
    
    @MainActor
    public func search(_ key:String) async {
        if await session.updateSearch(key) {
            logger.log("updated key: \(key)")
            self.viewData.id = key
            listViewData = GalleryListViewData()
            viewData.content = .idle
        }
    }
    
    
    private func observeFeed(stream: AsyncThrowingStream<[GalleryItem], Error>?) async  {
        logger.log("Started Observed feed")
        let stream =  await session.observeFeedStream()
            do {
                for try await content in stream {
                    let viewData = content.map{GalleryItemViewData(id: $0.id, isVideo: !($0.type == .image))}
                    await updateData(viewData)
                }
            }catch {
                
                await MainActor.run {
                    logger.log("Stopped Observed feed via throw:\(error) \(self.viewData.id) overall \(self.listViewData.items.count)")
                    if case .loading = viewData.content {
                        viewData.content = .error(.unknown)
                    }
                }
            }
        
        await MainActor.run(body: {
            logger.log("Stopped Observed feed: \(self.viewData.id) overall \(self.listViewData.items.count)")
            isObserving = false
            listViewData.hasMore = false
        })
       
    }
    
    @MainActor func updateData(_ data: [GalleryItemViewData]) {
        
        self.listViewData.items += data
        logger.log("Fetched key: \(self.viewData.id) \(data.count) overall \(self.listViewData.items.count)")
        if case .loading = viewData.content {
            logger.log("Updating to loading: \(self.viewData.id) \(data.count)")
            viewData.content = .loaded(listViewData)
        }
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
            guard index < content.count else {
                return
            }
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
    public var id: String = ""
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
    public let isVideo: Bool
    
    public init(image: UIImage? = nil, isLoading: Bool = false, id:String, isVideo: Bool) {
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
        self.isVideo = isVideo
        self.id = id
    }
    
    public init(imageName: String, isLoading: Bool = false, id:String, isVideo: Bool) {
        self.id = id
        self.isVideo = isVideo
        let image = Image(systemName: imageName)
        content = .loaded(image)
    }
    
    public init(content: Loadable<Image>, id:String, isVideo: Bool) {
        self.content = content
        self.id = id
        self.isVideo = isVideo
    }
    
    public func setLoading() -> Self {
        GalleryItemViewData(content: .loading, id: id, isVideo: isVideo)
    }
    
    public func set(_ image: UIImage) -> Self {
        let image = Image(uiImage: image)
        return GalleryItemViewData(content: .loaded(image), id: id, isVideo: isVideo)
    }
    
    public func setError(_ error: LoadableError) -> Self {
        GalleryItemViewData(content: .error(error), id: id, isVideo: isVideo)
    }
    
    
}


