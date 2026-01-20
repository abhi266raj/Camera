//
//  ImageClient.swift
//  CameraKit
//
//  Created by Abhiraj on 20/01/26.
//

import DomainApi
import PlatformApi
import UIKit

public struct ImageRepoImp: ImageRepo {
    
    private let networkClient: HTTPClient
    public init(networkClient: HTTPClient) {
        self.networkClient = networkClient
    }
    
    public func fetchImage(_ url: String) async throws -> UIImage {
        let operation = HTTPNetworkOperation(imageUrl: url)
        return await try networkClient.execute(operation)
    }
    
    
}

