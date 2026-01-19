//
//  NetworkService.swift
//  CameraKit
//
//  Created by Abhiraj on 19/01/26.
//

import Foundation

public protocol HTTPClient: Sendable {
    func execute<Response>(_ operation: HTTPNetworkOperation<Response>) async throws -> Response
}

public protocol HTTPRequestBuilder {
    func build() -> URLRequest?
}

public protocol HTTPResponseBuilder<Response> {
    associatedtype Response
    func createResponseFrom(data: Data) throws -> Response
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
}



