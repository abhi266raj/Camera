//
//  GalleryLoader.swift
//  CameraKit
//
//  Created by Abhiraj on 07/01/26.
//

import UIKit.UIImage

public enum MediaType: Sendable {
    case image
    case video
}

public struct GalleryItem: Sendable, Identifiable{
    public let id: String
    public let type: MediaType
    
    public init(id: String, type: MediaType = .image) {
        self.id = id
        self.type = type
    }
}

public struct GalleryContent: Sendable {
    public let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
}

public protocol GalleryLoader: Sendable, GalleryContentLoader {
    func loadGallery() async -> [GalleryItem]
}

public protocol GalleryContentLoader: Sendable {
    func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent
}

public struct ContentConfig: Sendable {
    public let width : Int
    public let height : Int
    public let requiresExactSize: Bool
    
    public init(width: Int, height: Int, requiresExactSize: Bool) {
        self.width = width
        self.height = height
        self.requiresExactSize = requiresExactSize
    }
}

public struct FetchConfig {
    
}

public enum LoaderError: Error, Sendable {
    case retryable(code: Int)
    case nonRetryable(code: Int)
    case inputError(code: Int)
    case cancelled
}

public protocol FeedLoader<Item>: Sendable {
    associatedtype Item
    func observeStream() async -> AsyncThrowingStream<[Item], Error>
    func loadInitial() async
    func loadMore() async
    func reset() async 
}


public protocol SearchAbleFeedLoader: FeedLoader {
    func updateSearchConfiguration(_ key: String, isVideo: Bool) async  -> Bool
}

