//
//  PexelGallerySession.swift
//  CameraKit
//
//  Created by Abhiraj on 17/01/26.
//

import UseCaseApi

public struct PexelGallerySession: GallerySession {
    private let feedLoader: PexelGalleryLoader
    private let contentLoader: GalleryContentLoader
    
    public init(feedLoader: PexelGalleryLoader, contentLoader: GalleryContentLoader) {
        self.feedLoader = feedLoader
        self.contentLoader = contentLoader
    }
    
    
    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        return try await contentLoader.loadContent(id: id, config: config)
    }
    
    public func updateSearch(_ key: String) async -> Bool {
        return await feedLoader.updateSearchConfiguration(key, isVideo: true)
    }
    
    public func observeFeedStream() async -> AsyncThrowingStream<[GalleryItem], Error> {
        return await feedLoader.observeStream()
    }
    public func loadInitial() async { await feedLoader.loadInitial() }
    public func loadMore() async { await feedLoader.loadMore() }
    public func reset() async { await feedLoader.reset() }
}
