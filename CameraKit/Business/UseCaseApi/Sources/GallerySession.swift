//
//  GallerySession.swift
//  CameraKit
//
//  Created by Abhiraj on 17/01/26.
//


public protocol GallerySession<Item>: Sendable {
    associatedtype Item
    func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent
    func observeFeedStream() async ->  AsyncThrowingStream<[Item], Error>
    func loadInitial() async
    func loadMore() async
    func reset() async
    func updateSearch(_ key: String) async -> Bool
}

public extension  GallerySession {
    func loadContent(id:String) async throws -> GalleryContent {
        let config = ContentConfig(width: 1500, height: 1500, requiresExactSize: false)
        return try await loadContent(id: id, config: config)
    }
    
    func loadThumbContent(id:String) async throws -> GalleryContent {
        let config = ContentConfig(width: 200, height: 200, requiresExactSize: true)
        return try await loadContent(id: id, config: config)
    }
}
