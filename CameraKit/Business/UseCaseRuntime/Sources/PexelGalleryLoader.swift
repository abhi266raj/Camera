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

private enum PexelEndPoint: Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case .curated:
            return "curated"
        case .search(let item):
            return "search:\(item)"
        case .searchVideo(let item):
            return "searchVideo:\(item)"
        }
    }
    
    case curated
    case search(String)
    case searchVideo(String)
}

public protocol RequestBuilder {
    func build() -> URLRequest?
}

public protocol ResponseBuilder<Response> {
    associatedtype Response
    func createResponseFrom(data: Data) throws -> Response
}

public struct NetworkOperation<Response> {
    let requestBuilder: RequestBuilder
    let responseBuilder: ResponseBuilder<Response>
    
    public init(responseType: Response.Type, requestBuilder: RequestBuilder) where Response: Decodable {
        self.requestBuilder = requestBuilder
        self.responseBuilder = DecodableResponseBuilder<Response>()
    }
}

protocol NetworkService: Sendable {
    func execute<Response>(_ operation: NetworkOperation<Response>) async throws -> Response
}

struct URLSessionNetworkService: NetworkService {
    
    let session: URLSession
    public init (session:URLSession = URLSession.shared) {
        self.session = session
    }
    
    func execute<Response>(_ operation: NetworkOperation<Response>) async throws -> Response {
        try await execute(requestBuilder: operation.requestBuilder, responseBuilder: operation.responseBuilder)
    }
    
    private func execute<Response>(requestBuilder: RequestBuilder, responseBuilder: ResponseBuilder<Response>) async throws -> Response {
        guard let request = requestBuilder.build() else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try responseBuilder.createResponseFrom(data: data)
        return response
    }
    
}

protocol GalleryResponse: Sendable {
    func asGalleryItem() -> [GalleryItem]
}

struct PexelsImageResponse: Decodable {
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

extension PexelsImageResponse: GalleryResponse {
    func asGalleryItem() -> [GalleryItem] {
        photos.map { GalleryItem(id: String($0.id), thumbUrl: $0.src.large2x) }
    }
}

struct PexelsVideoResponse: Decodable {
    struct Video: Decodable {
        let id: Int
        let image: String
        let videoFiles: [VideoFile]

        struct VideoFile: Decodable {
            let id: Int
           // let quality: String
            let fileType: String
            let link: String

            enum CodingKeys: String, CodingKey {
                case id
              //  case quality
                case fileType = "file_type"
                case link
            }
        }

        enum CodingKeys: String, CodingKey {
            case id
            case image
            case videoFiles = "video_files"
        }
    }

    let videos: [Video]
}

extension PexelsVideoResponse: GalleryResponse {
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

private struct DecodableResponseBuilder<DecodableResponse: Decodable>: ResponseBuilder {
    func createResponseFrom(data: Data) throws -> DecodableResponse {
        let response = try JSONDecoder().decode(DecodableResponse.self, from: data)
        return response
    }
}


private struct PexelRequestBuilder: RequestBuilder {
    
    private let apiKey: String = "2PMbPBg8WVNIAYWg3xNaVvXCZ8MYWksG240ITFczEEwQKXQaUJB6ekeT"
    private let scheme: String = "https"
    private let host: String = "api.pexels.com"
    
    private let page: Int
    private let endPoint: PexelEndPoint
    private let perPage: Int
    
    init(page: Int, endPoint: PexelEndPoint, perPage: Int) {
        self.page = page
        self.endPoint = endPoint
        self.perPage = perPage
    }
    
    func build() -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endPoint.path
        var items = [
            URLQueryItem(name: PexelQueryKey.page, value: "\(page)"),
            URLQueryItem(name: PexelQueryKey.perPage, value: "\(perPage)")
        ]
        if let list = endPoint.queryItems {
            items.append(contentsOf: list)
        }
        components.queryItems = items
        if let url = components.url  {
            var request = URLRequest(url:url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            return request
        }
        
        return nil
        
    }
    
}

extension PexelEndPoint {

    var path: String {
        switch self {
        case .curated:
            return "/v1/curated"
        case .search(_):
            return "/v1/search"
        case .searchVideo(_):
            return "/videos/search"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .curated:
            return nil
        case .search(let keyword):
            return [URLQueryItem(name: "query", value: keyword)]
        case .searchVideo(let keyword):
            return [URLQueryItem(name: "query", value: keyword)]
        }
    }
}

private enum PexelQueryKey {
    static let page = "page"
    static let perPage = "per_page"
}

public actor PexelGalleryLoader: SearchAbleFeedLoader {
    public typealias Item = GalleryItem
    let logger = Logger(subsystem: "Gallery", category: "Loader")
    
    private let networkService: NetworkService = URLSessionNetworkService()
    private struct Config {
        public let perPage: Int
        public let endPoint: PexelEndPoint
        
        public init(
            perPage: Int = 8,
            endPoint: PexelEndPoint = .curated
        ) {
            self.perPage = perPage
            self.endPoint = endPoint
        }
    }
    
    private var config: Config

    public init () {
        self.config = Config()
    }
    
    public func updateSearchConfiguration(_ key: String, isVideo: Bool) async  -> Bool {
        let endPoint: PexelEndPoint = {
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
            let items = try await buildApiResponse(page: page)
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
    
    private func buildApiResponse(page: Int) async throws -> [GalleryItem] {
        let requestBuilder = PexelRequestBuilder(page: page, endPoint: config.endPoint, perPage: config.perPage)
        if case .searchVideo(_) = config.endPoint {
            let operation = NetworkOperation(responseType: PexelsVideoResponse.self, requestBuilder: requestBuilder)
            let result = try await networkService.execute(operation)
            return result.asGalleryItem()
        } else {
            let operation = NetworkOperation(responseType: PexelsImageResponse.self, requestBuilder: requestBuilder)
            let result = try await networkService.execute(operation)
            return result.asGalleryItem()
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

