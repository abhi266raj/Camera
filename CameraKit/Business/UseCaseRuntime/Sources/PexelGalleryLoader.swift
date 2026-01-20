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

import PlatformApi
import DomainApi
import Foundation
import UIKit.UIImage
import UseCaseApi
import CoreKit
internal import OSLog


//struct PexelWebClient: GalleryItemClient {
//    typealias GalleryItemType = PexelGalleryItem
//    private let networkService: HTTPClient
//    
//    init(networkService: HTTPClient) {
//        self.networkService = networkService
//    }
//    
//    func fetchGalleryItems(type: PexelGalleryItem, page: Int, perPage: Int) async throws -> PexelGalleryResponse {
//        await try self.fetchGalleryItems(page: page, endPoint: type, perPage: perPage)
//    }
//   
//    
//    private func fetchGalleryItems(page: Int, endPoint: PexelGalleryItem, perPage: Int) async throws -> PexelGalleryResponse {
//        let requestBuilder = PexelRequestBuilder(page: page, endPoint: endPoint, perPage: perPage)
//        if case .searchVideo(_) = endPoint {
//            let operation = HTTPNetworkOperation(responseType: PexelsVideoResponse.self, requestBuilder: requestBuilder)
//            let result = try await networkService.execute(operation)
//            return .video(result)
//        } else {
//            let operation = HTTPNetworkOperation(responseType: PexelsImageResponse.self, requestBuilder: requestBuilder)
//            let result = try await networkService.execute(operation)
//            return .image(result)
//        }
//    }
//    
//    private struct PexelRequestBuilder: HTTPRequestBuilder {
//        
//        private let apiKey: String = "2PMbPBg8WVNIAYWg3xNaVvXCZ8MYWksG240ITFczEEwQKXQaUJB6ekeT"
//        private let scheme: String = "https"
//        private let host: String = "api.pexels.com"
//        
//        private let page: Int
//        private let endPoint: PexelGalleryItem
//        private let perPage: Int
//        
//        init(page: Int, endPoint: PexelGalleryItem, perPage: Int) {
//            self.page = page
//            self.endPoint = endPoint
//            self.perPage = perPage
//        }
//        
//        func build() -> URLRequest? {
//            var components = URLComponents()
//            components.scheme = scheme
//            components.host = host
//            components.path = endPoint.path
//            var items = [
//                URLQueryItem(name: PexelQueryKey.page, value: "\(page)"),
//                URLQueryItem(name: PexelQueryKey.perPage, value: "\(perPage)")
//            ]
//            if let list = endPoint.queryItems {
//                items.append(contentsOf: list)
//            }
//            components.queryItems = items
//            if let url = components.url  {
//                var request = URLRequest(url:url)
//                request.setValue(apiKey, forHTTPHeaderField: "Authorization")
//                return request
//            }
//            
//            return nil
//            
//        }
//        
//    }
//    
//    private enum PexelQueryKey {
//        static let page = "page"
//        static let perPage = "per_page"
//    }
//}
//
//
//extension PexelGalleryItem: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .curated:
//            return "curated"
//        case .search(let item):
//            return "search:\(item)"
//        case .searchVideo(let item):
//            return "searchVideo:\(item)"
//        }
//    }
//    
//    var path: String {
//        switch self {
//        case .curated:
//            return "/v1/curated"
//        case .search(_):
//            return "/v1/search"
//        case .searchVideo(_):
//            return "/videos/search"
//        }
//    }
//    
//    var queryItems: [URLQueryItem]? {
//        switch self {
//        case .curated:
//            return nil
//        case .search(let keyword):
//            return [URLQueryItem(name: "query", value: keyword)]
//        case .searchVideo(let keyword):
//            return [URLQueryItem(name: "query", value: keyword)]
//        }
//    }
//}


extension PexelGalleryResponse {
    func asGalleryItem() -> [GalleryItem] {
        switch self {
        case .image(let item):
            return item.asGalleryItem()
        case .video(let item):
            return item.asGalleryItem()
        }
    }
}

extension PexelsImageResponse {
    func asGalleryItem() -> [GalleryItem] {
        photos.map { GalleryItem(id: String($0.id), thumbUrl: $0.src.large2x) }
    }
}

extension PexelsVideoResponse {
    func asGalleryItem() -> [GalleryItem] {
        videos.compactMap { video in
            let url = {
                if video.videoFiles.isEmpty {
                    return  ""
                }
                return video.videoFiles[0].link
            }()
            return GalleryItem(id: String(video.id), thumbUrl: video.image, type: .video(url))
        }
    }
}

public actor PexelGalleryLoader: SearchAbleFeedLoader {
    public typealias Item = GalleryItem
    let logger = Logger(subsystem: "Gallery", category: "Loader")
    
    private let webClient: GalleryItemClient<PexelGalleryItem, PexelGalleryResponse>
    private struct Config {
        public let perPage: Int
        public let endPoint: PexelGalleryItem
        
        public init(
            perPage: Int = 8,
            endPoint: PexelGalleryItem = .curated
        ) {
            self.perPage = perPage
            self.endPoint = endPoint
        }
    }
    
    private var config: Config

    public init (webClinet: GalleryItemClient<PexelGalleryItem, PexelGalleryResponse>) {
        self.config = Config()
        self.webClient =  webClinet
    }
    
    public func updateSearchConfiguration(_ key: String, isVideo: Bool) async  -> Bool {
        let endPoint: PexelGalleryItem = {
            if key == "" {
                return .curated
            }
            
            if isVideo {
                return .searchVideo(key)
            }
            return .search(key)
        }()
        
        
         if endPoint == config.endPoint {
            return false
        }
        
        config = Config(endPoint: endPoint)
        await reset()
        return true
        
    }
    
    private struct State {
        var currentPage: Int = 0
        var isComplete: Bool = false
        var isLoading: Bool = false
        var continuation: AsyncThrowingStream<[Item], Error>.Continuation?
        
    }
    
    private var state = State()
    
    public var canLoad: Bool {
        !state.isLoading && !state.isComplete
    }
    
    // MARK: - ContentLoader
    
    nonisolated public func observeStream() async -> AsyncThrowingStream<[Item], Error> {
        let stream = AsyncThrowingStream.makeStream(of: [Item].self)
        await setUp(with: stream.continuation)
        return stream.stream
    }
    
    func setUp(with continuation: AsyncThrowingStream<[Item], Error>.Continuation) {
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
    
    private func loadPage(page: Int) async  {
        do {
            let result = try await webClient.fetchGalleryItems(type: config.endPoint, page: page, perPage: config.perPage)
            let items = result.asGalleryItem()
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
            logger.log("Network Error\(error.localizedDescription)")
            state.isComplete = true
            state.continuation?.finish(throwing: error)
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

