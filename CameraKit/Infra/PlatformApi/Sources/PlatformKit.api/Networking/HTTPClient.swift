//
//  NetworkService.swift
//  CameraKit
//
//  Created by Abhiraj on 19/01/26.
//

import Foundation
import UIKit.UIImage

public protocol HTTPClient: Sendable {
    func execute<Response>(_ operation: HTTPNetworkOperation<Response>) async throws -> Response
}

public protocol HTTPRequestBuilder {
    func build() -> URLRequest?
}

extension String: HTTPRequestBuilder {
    public func build() -> URLRequest? {
        let url = URL(string: self)
        guard let url else {
            return nil
        }
        return URLRequest(url: url)
    }
}

public protocol HTTPResponseBuilder<Response> {
    associatedtype Response
    func createResponseFrom(data: Data) throws -> Response
}

fileprivate struct DataResponseBuilder: HTTPResponseBuilder {
    func createResponseFrom(data: Data) throws -> Data {
        return data
    }
}

fileprivate struct ImageResponseBuilder: HTTPResponseBuilder {
    func createResponseFrom(data: Data) throws -> UIImage {
        let image = UIImage(data: data)
        guard let image else {
            throw URLError(.badServerResponse)
        }
        return image
    }
}


public struct HTTPNetworkOperation<Response> {
    public let requestBuilder: HTTPRequestBuilder
    public let responseBuilder: HTTPResponseBuilder<Response>
    
    private struct DecodableResponseBuilder<DecodableResponse: Decodable>: HTTPResponseBuilder {
        func createResponseFrom(data: Data) throws -> DecodableResponse {
            let response = try JSONDecoder().decode(DecodableResponse.self, from: data)
            return response
        }
    }
    
    public init(responseType: Response.Type, requestBuilder: HTTPRequestBuilder) where Response: Decodable {
        self.requestBuilder = requestBuilder
        self.responseBuilder = DecodableResponseBuilder<Response>()
    }
    
    public init(requestBuilder: HTTPRequestBuilder, responseBuilder: HTTPResponseBuilder<Response>) {
        self.requestBuilder = requestBuilder
        self.responseBuilder = responseBuilder
    }
    
    public init(imageUrl: String) where Response == UIImage {
        self.requestBuilder = imageUrl
        self.responseBuilder = ImageResponseBuilder()
    }
}



