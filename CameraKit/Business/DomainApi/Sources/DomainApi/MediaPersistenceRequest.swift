//
//  MediaPersistenceRequest.swift
//  CameraKit
//
//  Created by Abhiraj on 02/01/26.
//

import Foundation

/// Enum representing what kind of media to save.
public enum MediaPersistenceRequest {
    //case image(UIImage)
    case video(URL)
    // case imageFromURL(URL)
    case imageData(Data)
}


public protocol MediaPersistenceService {
    func save(_ request: MediaPersistenceRequest) async throws
}
