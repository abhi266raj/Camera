//
//  PexelGalleryLoader.swift
//  CameraKit
//
//  Created by Assistant on 15/01/26.
//

import Foundation
import UIKit.UIImage
import UseCaseApi
import CoreKit

public struct PexelGalleryLoader: GalleryLoader {
    public init() {}
    
    // Replace with your actual Pexels API key
    private let apiKey = "YOUR_PEXELS_API_KEY"
    private let baseURL = "https://api.pexels.com/v1/curated?page=1&per_page=40"
    
    public func loadGallery() async -> [GalleryItem] {
        guard let url = URL(string: baseURL) else { return [] }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let items = parseGalleryItems(from: data) {
                return items
            }
        } catch {
            return []
        }
        return []
    }

    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        guard let url = URL(string: id) else { throw RequestError.invalidInput }
        let maxDimension = min(config.width, config.height, 1000)
        let size = CGSize(width: maxDimension, height: maxDimension)
        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard var image = UIImage(data: data) else { throw RequestError.invalidInput }
            if Int(image.size.width) > maxDimension || Int(image.size.height) > maxDimension {
                image = resize(image: image, targetSize: size) ?? image
            }
            return GalleryContent(image: image)
        } catch {
            throw RequestError.invalidInput
        }
    }

    // MARK: - Helpers

    private func parseGalleryItems(from data: Data) -> [GalleryItem]? {
        struct PexelsResponse: Decodable {
            struct Photo: Decodable {
                let id: Int
                let src: Src
                struct Src: Decodable {
                    let original: String
                    let large2x: String
                }
            }
            let photos: [Photo]
        }
        do {
            let response = try JSONDecoder().decode(PexelsResponse.self, from: data)
            // Use 'large2x' which is typically less than or equal to 1000x1000 px, fallback to 'original'
            return response.photos.map { GalleryItem(id: $0.src.large2x) }
        } catch {
            return nil
        }
    }

    private func resize(image: UIImage, targetSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
