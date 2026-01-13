//
//  GalleryLoader.swift
//  CameraKit
//
//  Created by Abhiraj on 07/01/26.
//

import UIKit.UIImage

public struct GalleryItem: Sendable, Identifiable{
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct GalleryContent: Sendable {
    public let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
}

public protocol GalleryLoader: Sendable {
    func loadGallery() async -> [GalleryItem]
    func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent
}

public extension  GalleryLoader {
    func loadContent(id:String) async throws -> GalleryContent {
        let config = ContentConfig(width: 1500, height: 1500, requiresExactSize: false)
        return try await loadContent(id: id, config: config)
    }
    
    func loadThumbContent(id:String) async throws -> GalleryContent {
        let config = ContentConfig(width: 500, height: 500, requiresExactSize: true)
        return try await loadContent(id: id, config: config)
    }
}

public struct ContentConfig {
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


