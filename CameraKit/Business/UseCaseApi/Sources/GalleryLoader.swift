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
    func loadContent(id: String) async throws -> GalleryContent
}
