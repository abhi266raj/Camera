//
//  PexelGallerySession.swift
//  CameraKit
//
//  Created by Abhiraj on 17/01/26.
//

import UseCaseApi
import Foundation
import Synchronization

actor SessionCache:  Sendable {
    
    var content: [String:GalleryItem] = [:]
    
    public func cahcedList(_ list:[GalleryItem]) -> [GalleryItem] {
        for item in list {
            content[item.id] = item
        }
        return list
    }
    
    public func thumbFor(_ id:String) async -> String? {
        let item = content[id]?.thumbUrl
        return item
    }
    
    public func videoUrl(_ id:String) async -> String? {
        let type = content[id]?.type
        if case .video(let string) = type {
            return string
        }
        return nil
    }
    
    public func reset() {
        content.removeAll()
    }
}

public struct PexelGallerySession: GallerySession {
    private let feedLoader: PexelGalleryLoader
    private let contentLoader: GalleryContentLoader
    private let cache = SessionCache()
    
    public init(feedLoader: PexelGalleryLoader, contentLoader: GalleryContentLoader) {
        self.feedLoader = feedLoader
        self.contentLoader = contentLoader
    }
    
    
    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        let item = await cache.thumbFor(id)
        guard let item else {
            throw URLError(.unknown)
        }
        return try await contentLoader.loadContent(id: item, config: config)
    }
    
    public func videoUrl(id:String) async throws -> URL {
        let item = await cache.videoUrl(id)
        guard let item else {
            throw URLError(.unknown)
        }
        guard let url =  URL(string: item) else {
            throw URLError(.unknown)
        }
        return url
    }
    
    public func updateSearch(_ key: String) async -> Bool {
        return await feedLoader.updateSearchConfiguration(key, isVideo: true)
    }
    
    public func observeFeedStream() async -> AsyncSequence<[GalleryItem], Error> {
        await cache.reset()
        let stream = await feedLoader.observeStream().map { list throws in
            let result = await cache.cahcedList(list)
            return result
        }
        
        return stream
    }
    public func loadInitial() async { await feedLoader.loadInitial() }
    public func loadMore() async { await feedLoader.loadMore() }
    public func reset() async { await feedLoader.reset() }
}
