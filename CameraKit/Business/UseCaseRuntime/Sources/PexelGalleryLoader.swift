//
//  PexelGalleryLoader.swift
//  CameraKit
//
//  Created by Abhiraj on 15/01/26.
//

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

public actor PexelGalleryLoader: FeedLoader {
    public typealias Item = GalleryItem

    private struct Config {
        public let apiKey: String
        public let perPage: Int
        public let baseURL: String
        
        public init(apiKey: String = "2PMbPBg8WVNIAYWg3xNaVvXCZ8MYWksG240ITFczEEwQKXQaUJB6ekeT",
                    perPage: Int = 8,
                    baseURL: String = "https://api.pexels.com/v1/curated?page=1&per_page=8") {
            self.apiKey = apiKey
            self.perPage = perPage
            self.baseURL = baseURL
        }
    }
    
    private let config: Config


    public init () {
        self.config = Config()
    }
    
    private struct State {
        var currentPage: Int = 0
        var isComplete: Bool = false
        var isLoading: Bool = false
        var continuation: AsyncThrowingStream<[GalleryItem], Error>.Continuation?
    }
    
    private var state = State()
    
    public var canLoad: Bool {
        !state.isLoading && !state.isComplete
    }
    
    // MARK: - ContentLoader
    
    nonisolated public func observeStream() -> AsyncThrowingStream<[GalleryItem], Error> {
        let stream = AsyncThrowingStream.makeStream(of: [GalleryItem].self)
        defer {
            Task {
                await setUp(with: stream.continuation)
            }
        }
        return stream.stream
    }
    
    func setUp(with continuation: AsyncThrowingStream<[GalleryItem], Error>.Continuation) {
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
        await reset()
        state.isLoading = true
        try? await loadPage(page: 1)
        state.isLoading = false
        state.currentPage += 1
    }
    
    public func loadMore() async  {
        guard canLoad else { return }
        state.isLoading = true
        try? await loadPage(page: state.currentPage + 1)
        state.isLoading = false
        state.currentPage += 1
    }
    
    public func reset() async {
        state.continuation?.finish()
        state = State()
    }
    
    // MARK: - Private Helpers
    
    private func urlForPage(_ page: Int) -> URL? {
        URL(string: "https://api.pexels.com/v1/curated?page=\(page)&per_page=\(config.perPage)")
    }
    
    private func loadPage(page: Int) async  {
        guard let url = urlForPage(page) else { return }
        var request = URLRequest(url: url)
        request.setValue(config.apiKey, forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let items = parseGalleryItems(from: data) else {
                state.isComplete = true
                state.continuation?.finish()
                return
            }
            
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
            state.isComplete = true
            state.continuation?.finish(throwing: error)
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
}


public struct PexelFeedContentLoader: GalleryContentLoader {
    
    public init () {
        
    }
    
    public func loadContent(id: String, config: ContentConfig) async throws -> GalleryContent {
        guard let url = URL(string: id) else { throw RequestError.invalidInput }
        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard var image = UIImage(data: data) else { throw RequestError.invalidInput }
            return GalleryContent(image: image)
        } catch {
            throw RequestError.invalidInput
        }
    }
}
