//
//  URLSessionNetworkService.swift
//  CameraKit
//
//  Created by Abhiraj on 19/01/26.
//

import DomainApi
import Foundation

public struct URLSessionNetworkService: NetworkService {
    
    let session: URLSession
    public init (session:URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func execute<Response>(_ operation: NetworkOperation<Response>) async throws -> Response {
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
