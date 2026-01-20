//
//  GalleryItemClient.swift
//  CameraKit
//
//  Created by Abhiraj on 20/01/26.
//


public enum PexelGalleryResponse {
    case image(PexelsImageResponse)
    case video(PexelsVideoResponse)
}

public enum PexelGalleryItem: Sendable, Equatable {
    case curated
    case search(String)
    case searchVideo(String)
}

extension PexelGalleryItem: CustomStringConvertible {
    public var description: String {
        switch self {
        case .curated:
            return "curated"
        case .search(let item):
            return "search:\(item)"
        case .searchVideo(let item):
            return "searchVideo:\(item)"
        }
    }
}

public protocol GalleryItemClient<GalleryItemInput, GalleryItemOutput>: Sendable {
    associatedtype GalleryItemInput
    associatedtype GalleryItemOutput
    func fetchGalleryItems(type: GalleryItemInput, page: Int, perPage: Int) async throws -> GalleryItemOutput
}

public struct PexelsImageResponse: Decodable {
    public struct Photo: Decodable {
        public let id: Int
        public let src: Src
        public struct Src: Decodable {
            public let original: String
            public let large2x: String
        }
    }
    public let photos: [Photo]
}

public struct PexelsVideoResponse: Decodable {
    public struct Video: Decodable {
        public let id: Int
        public let image: String
        public let videoFiles: [VideoFile]
        
        public struct VideoFile: Decodable {
            public let id: Int
           // let quality: String
            public let fileType: String
            public let link: String
            
            private enum CodingKeys: String, CodingKey {
                case id
              //  case quality
                case fileType = "file_type"
                case link
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case id
            case image
            case videoFiles = "video_files"
        }
    }
    
    public let videos: [Video]
}
