//
//  NetworkService.swift
//  CameraKit
//
//  Created by Abhiraj on 19/01/26.
//

import Foundation

public protocol NetworkService: Sendable {
    func execute<Response>(_ operation: NetworkOperation<Response>) async throws -> Response
}

public protocol RequestBuilder {
    func build() -> URLRequest?
}

public protocol ResponseBuilder<Response> {
    associatedtype Response
    func createResponseFrom(data: Data) throws -> Response
}


public struct NetworkOperation<Response> {
    public let requestBuilder: RequestBuilder
    public let responseBuilder: ResponseBuilder<Response>
    
    private struct DecodableResponseBuilder<DecodableResponse: Decodable>: ResponseBuilder {
        func createResponseFrom(data: Data) throws -> DecodableResponse {
            let response = try JSONDecoder().decode(DecodableResponse.self, from: data)
            return response
        }
    }
    
    public init(responseType: Response.Type, requestBuilder: RequestBuilder) where Response: Decodable {
        self.requestBuilder = requestBuilder
        self.responseBuilder = DecodableResponseBuilder<Response>()
    }
    
    public init(requestBuilder: RequestBuilder, responseBuilder: ResponseBuilder<Response>) {
        self.requestBuilder = requestBuilder
        self.responseBuilder = responseBuilder
    }
}



