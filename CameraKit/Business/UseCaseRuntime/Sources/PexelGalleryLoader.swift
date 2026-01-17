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
internal import OSLog

private enum Endpoint: Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case .curated:
            return "curated"
        case .search(let item):
            return "search:\(item)"
        }
    }
    
    case curated
    case search(String)

    var path: String {
        switch self {
        case .curated:
            return "/v1/curated"
        case .search(_):
            return "/v1/search"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .curated:
            return nil
        case .search(let keyword):
            return [URLQueryItem(name: "query", value: keyword)]
        }
    }
}

private enum QueryKey {
    static let page = "page"
    static let perPage = "per_page"
}

public actor PexelGalleryLoader: SearchAbleFeedLoader {
    // public typealias Item = GalleryItem
    let logger = Logger(subsystem: "Gallery", category: "Loader")
    private struct Config {
        public let apiKey: String
        public let perPage: Int
        public let scheme: String
        public let host: String
        public let endPoint: Endpoint
        
        public init(
            apiKey: String = "2PMbPBg8WVNIAYWg3xNaVvXCZ8MYWksG240ITFczEEwQKXQaUJB6ekeT",
            perPage: Int = 8,
            scheme: String = "https",
            host: String = "api.pexels.com",
            endPoint: Endpoint = .search("apple")
        ) {
            self.apiKey = apiKey
            self.perPage = perPage
            self.scheme = scheme
            self.host = host
            self.endPoint = endPoint
        }
    }
    
    private var config: Config

    public init () {
        self.config = Config()
    }
    
    public func updateSearchConfiguration(_ key: String) async  -> Bool {
        if case .search(let string)  = config.endPoint {
            if string == key {return false}
        }
  
        let endpoint = Endpoint.search(key)
        config = Config(endPoint: endpoint)
        await reset()
        return true
        
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
    
    nonisolated public func observeStream() async -> AsyncThrowingStream<[GalleryItem], Error> {
        let stream = AsyncThrowingStream.makeStream(of: [GalleryItem].self)
        await setUp(with: stream.continuation)
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
        logger.log("Inital load Started \(self.config.endPoint) \(self.state.currentPage)")
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
    
    /**
     Constructs a URL for a given endpoint and page, using endpoint's path and extra query parameters.
     */
    private func urlForPage(_ page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = config.host
        components.path = config.endPoint.path
        var items = [
            URLQueryItem(name: QueryKey.page, value: "\(page)"),
            URLQueryItem(name: QueryKey.perPage, value: "\(config.perPage)")
        ]
        if let list = config.endPoint.queryItems {
            items.append(contentsOf: list)
        }
        components.queryItems = items
        return components.url
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

