//
//  PexelWebClient.swift
//  CameraKit
//
//  Created by Abhiraj on 20/01/26.
//


import PlatformApi
import DomainApi
import Foundation
import UIKit.UIImage
import UseCaseApi
import CoreKit
internal import OSLog


public struct PexelWebClient: GalleryItemClient {
    typealias GalleryItemType = PexelGalleryItem
    private let networkService: HTTPClient
    
    public init(networkService: HTTPClient) {
        self.networkService = networkService
    }
    
    public func fetchGalleryItems(type: PexelGalleryItem, page: Int, perPage: Int) async throws -> PexelGalleryResponse {
        await try self.fetchGalleryItems(page: page, endPoint: type, perPage: perPage)
    }
   
    private func fetchGalleryItems(page: Int, endPoint: PexelGalleryItem, perPage: Int) async throws -> PexelGalleryResponse {
        let requestBuilder = PexelRequestBuilder(page: page, endPoint: endPoint, perPage: perPage)
        if case .searchVideo(_) = endPoint {
            let operation = HTTPNetworkOperation(responseType: PexelsVideoResponse.self, requestBuilder: requestBuilder)
            let result = try await networkService.execute(operation)
            return .video(result)
        } else {
            let operation = HTTPNetworkOperation(responseType: PexelsImageResponse.self, requestBuilder: requestBuilder)
            let result = try await networkService.execute(operation)
            return .image(result)
        }
    }
    
    private struct PexelRequestBuilder: HTTPRequestBuilder {
        
        private let apiKey: String = "2PMbPBg8WVNIAYWg3xNaVvXCZ8MYWksG240ITFczEEwQKXQaUJB6ekeT"
        private let scheme: String = "https"
        private let host: String = "api.pexels.com"
        
        private let page: Int
        private let endPoint: PexelGalleryItem
        private let perPage: Int
        
        init(page: Int, endPoint: PexelGalleryItem, perPage: Int) {
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
    
    private enum PexelQueryKey {
        static let page = "page"
        static let perPage = "per_page"
    }
}

private extension PexelGalleryItem {
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
