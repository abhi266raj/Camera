//
//  GalleryViewModel.swift
//  CameraKit
//
//  Created by Abhiraj on 06/01/26.
//


// MARK: - ViewModel

internal import Photos
internal import UIKit
import SwiftUI
import Observation
import UseCaseApi
import UseCaseRuntime


public final class GalleryViewModel: Sendable  {
    @MainActor var  items: [PHAsset] = []
    @MainActor public let viewData: GalleryListViewData = GalleryListViewData()
    private let galleryLoader:GalleryLoader
    
    @MainActor
    public init(galleryLoader: GalleryLoader) {
        self.galleryLoader = galleryLoader
    }

    public func load() async {
        var status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        if status == .authorized || status == .limited {
            await fetchAssets()
        }
    }

    @MainActor
    private func fetchAssets() async {
        viewData.items = await galleryLoader.loadGallery().map{GalleryItemViewData(id: $0.id)}
    }
    
    @MainActor
    public func loadThumbnail(id: String) async  {
        guard let index =  viewData.items.firstIndex(where: { $0.id == id}) else {
            return
        }
        if viewData.items[index].isLoading  {
            return
        }
        await viewData.items[index] = .init(isLoading: true, id: id)
        let image = try? await galleryLoader.loadContent(id: id).image
        await viewData.items[index] = .init(image: image, id: id)
    }
}

@Observable
@MainActor
public class GalleryListViewData: Sendable {
    
    public var count: Int {
        items.count
    }
    
    public var items: [GalleryItemViewData] = []
    
}


public struct GalleryItemViewData:Identifiable, Equatable, Sendable {
    public let image: Image?
    public let isLoading: Bool
    public let id:String
    
    public init(image: UIImage? = nil, isLoading: Bool = false, id:String) {
        if let image {
            self.image = Image(uiImage: image)
        }else {
            self.image = nil
        }
        self.isLoading = false
        self.id = id
    }
    
    public init(imageName: String, isLoading: Bool = false, id:String) {
        self.isLoading = false
        self.id = id
        self.image = Image(systemName: imageName)
        
    }
    
}
