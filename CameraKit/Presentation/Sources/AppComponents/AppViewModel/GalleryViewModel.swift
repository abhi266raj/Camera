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


public final class GalleryViewModel: Sendable  {
    @MainActor var  items: [PHAsset] = []
    @MainActor public let viewData: GalleryListViewData = GalleryListViewData()
    
    @MainActor
    public init() {
        
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

    private func fetchAssets() async {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: options)
        await updateViewData(result: result)
    }
    
    @MainActor
    func updateViewData(result: PHFetchResult<PHAsset>) {
        items = result.objects(at: IndexSet(integersIn: 0..<result.count))
        viewData.items = items.map{GalleryItemViewData(id: $0.localIdentifier)}
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
        let asset = items[index]
        let manager = PHImageManager.default()
        let size = CGSize(width: 1500, height: 1500)
        var didResume = false
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        let image = await withCheckedContinuation { continuation in
            manager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                guard !didResume else { return }
                didResume = true
                continuation.resume(returning: image)
            }
        }
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
