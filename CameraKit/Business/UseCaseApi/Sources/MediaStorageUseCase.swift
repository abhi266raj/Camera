
import Foundation

public enum MediaContent {
    //case image(UIImage)
    case video(URL)
    // case imageFromURL(URL)
    case imageData(Data)
}


public protocol MediaStorageUseCase {
    func save(_ content: MediaContent) async throws
}


