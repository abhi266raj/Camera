//
//  PexelGalleryLoader.swift
//  CameraKit
//
//  Created by Abhiraj on 15/01/26.
//


import PlatformApi
import DomainApi
import Foundation
import UIKit.UIImage
import UseCaseApi
import CoreKit
internal import OSLog


extension PexelGalleryResponse {
    func asGalleryItem() -> [GalleryItem] {
        switch self {
        case .image(let item):
            return item.asGalleryItem()
        case .video(let item):
            return item.asGalleryItem()
        }
    }
}

extension PexelsImageResponse {
    func asGalleryItem() -> [GalleryItem] {
        photos.map { GalleryItem(id: String($0.id), thumbUrl: $0.src.large2x) }
    }
}

extension PexelsVideoResponse {
    func asGalleryItem() -> [GalleryItem] {
        videos.compactMap { video in
            let url = {
                if video.videoFiles.isEmpty {
                    return  ""
                }
                return video.videoFiles[0].link
            }()
            return GalleryItem(id: String(video.id), thumbUrl: video.image, type: .video(url))
        }
    }
}

public actor PexelGalleryLoader: SearchAbleFeedLoader {
    public typealias Item = GalleryItem
    let logger = Logger(subsystem: "Gallery", category: "Loader")
    
    private let webClient: GalleryItemClient<PexelGalleryItem, PexelGalleryResponse>
    private struct Config {
        public let perPage: Int
        public let endPoint: PexelGalleryItem
        
        public init(
            perPage: Int = 8,
            endPoint: PexelGalleryItem = .curated
        ) {
            self.perPage = perPage
            self.endPoint = endPoint
        }
    }
    
    private var config: Config

    public init (webClinet: GalleryItemClient<PexelGalleryItem, PexelGalleryResponse>) {
        self.config = Config()
        self.webClient =  webClinet
    }
    
    public func updateSearchConfiguration(_ key: String, isVideo: Bool) async  -> Bool {
        let endPoint: PexelGalleryItem = {
            if key == "" {
                return .curated
            }
            
            if isVideo {
                return .searchVideo(key)
            }
            return .search(key)
        }()
        
        
         if endPoint == config.endPoint {
            return false
        }
        
        config = Config(endPoint: endPoint)
        await reset()
        return true
        
    }
    
    private struct State {
        var currentPage: Int = 0
        var isComplete: Bool = false
        var isLoading: Bool = false
        var continuation: AsyncThrowingStream<[Item], Error>.Continuation?
        
    }
    
    private var state = State()
    
    public var canLoad: Bool {
        !state.isLoading && !state.isComplete
    }
    
    // MARK: - ContentLoader
    
    nonisolated public func observeStream() async -> AsyncThrowingStream<[Item], Error> {
        let stream = AsyncThrowingStream.makeStream(of: [Item].self)
        await setUp(with: stream.continuation)
        return stream.stream
    }
    
    func setUp(with continuation: AsyncThrowingStream<[Item], Error>.Continuation) {
        if let current = self.state.continuation {
            current.finish(throwing: LoaderError.cancelled)
        }
        
        if state.isComplete {
            continuation.finish()
            return
        }
        state.continuation = continuation
    }
    
    public func loadInitial() async  {
        state.isLoading = true
        try? await loadPage(page: 1)
        state.isLoading = false
        state.currentPage += 1
        logger.log("Inital load End \(self.config.endPoint) \(self.state.currentPage)")
    }
    
    public func loadMore() async  {
        guard canLoad else {
            return
        }
        state.isLoading = true
        try? await loadPage(page: state.currentPage + 1)
        state.isLoading = false
        state.currentPage += 1
    }
    
    public func reset() async {
        while state.isLoading {
            logger.log("infinte waiting")
            await Task.yield()
        }
        state.continuation?.finish()
        logger.log("finshed contination")
        state = State()
    }
    
    private func loadPage(page: Int) async  {
        do {
            let result = try await webClient.fetchGalleryItems(type: config.endPoint, page: page, perPage: config.perPage)
            let items = result.asGalleryItem()
            if items.isEmpty {
                state.isComplete = true
                state.continuation?.finish()
                return
            }
            
            state.currentPage = page
            state.continuation?.yield(items)
            
            if items.count < config.perPage {
                state.isComplete = true
                state.continuation?.finish()
            }
        } catch (let error as Error) {
            logger.log("Network Error\(error.localizedDescription)")
            state.isComplete = true
            state.continuation?.finish(throwing: error)
        }
    }
}

public struct PexelFeedContentLoader: GalleryContentLoader {
    
    private let imageRepo: ImageRepo
    public init (imageRepo: ImageRepo) {
        self.imageRepo = imageRepo
    }
    
    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        let image = await try imageRepo.fetchImage(id)
        return GalleryContent(image: image)
    }
}

