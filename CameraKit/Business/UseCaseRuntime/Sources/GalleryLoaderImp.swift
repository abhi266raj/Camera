//
//  GalleryLoader.swift
//  CameraKit
//
//  Created by Abhiraj on 07/01/26.
//

import Foundation
import UseCaseApi
import Photos
import CoreKit

public struct GalleryLoaderImp: GalleryLoader {
    public init() {
        
    }
    public func loadGallery() async -> [GalleryItem] {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: options)
        let list = result.objects(at: IndexSet(integersIn: 0..<result.count))
        return list.map{GalleryItem(id: $0.localIdentifier)}
    }
    
    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        guard let asset = fetchAsset(by: id) else {
            throw RequestError.invalidInput
        }
        let manager = PHImageManager.default()
        let size = CGSize(width: config.width, height: config.height)
        var didResume = false
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        if config.requiresExactSize {
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
        }
        else {
            options.deliveryMode = .fastFormat
        }
        options.isSynchronous = false
        
        let image = await withCheckedContinuation { continuation in
            manager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                guard !didResume else { return }
                didResume = true
                continuation.resume(returning: image)
            }
        }
        guard let image else {
            throw RequestError.invalidInput
        }
        return GalleryContent(image: image)
    }
    
    private func fetchAsset(by id: String) -> PHAsset? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return assets.firstObject
    }
}
