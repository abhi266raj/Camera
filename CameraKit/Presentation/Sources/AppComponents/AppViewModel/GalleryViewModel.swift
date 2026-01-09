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
import DomainApi


public final class GalleryViewModel: Sendable  {
    @MainActor var  items: [PHAsset] = []
    @MainActor public let viewData: GalleryViewData = GalleryViewData()
    @MainActor public let listViewData: GalleryListViewData = GalleryListViewData()
    private let galleryLoader:GalleryLoader
    private let permissionSerivce: PermissionService
    
    @MainActor
    public var showDetail: ((GalleryItemViewData) -> Void)? = nil
    
    @MainActor
    public init(galleryLoader: GalleryLoader, permissionService: PermissionService) {
        self.galleryLoader = galleryLoader
        self.permissionSerivce = permissionService
    }

    @MainActor
    public func load() async {
        let isPermitted = await permissionSerivce.requestGalleryAccess()
        if !isPermitted {
            viewData.state = .denied
        } else {
            listViewData.items = []
            viewData.state = .loading
            await fetchAssets()
            viewData.state = .permitted(listViewData)
        }
    }

    @MainActor
    private func fetchAssets() async {
        listViewData.items = await galleryLoader.loadGallery().map{GalleryItemViewData(id: $0.id)}
    }
    
    @MainActor
    public func loadThumbnail(id: String) async  {
        guard let index =  listViewData.items.firstIndex(where: { $0.id == id}) else {
            return
        }
        if listViewData.items[index].isLoading  {
            return
        }
        await listViewData.items[index] = .init(isLoading: true, id: id)
        let image = try? await galleryLoader.loadContent(id: id).image
        await listViewData.items[index] = .init(image: image, id: id)
    }
    
    @MainActor
    public func tappedOnItem(id: String) async {
        guard let index =  listViewData.items.firstIndex(where: { $0.id == id}) else {
            return
        }
        let data = listViewData.items[index]
        showDetail?(data)
        
    }
    
    
}

@Observable
@MainActor
public class GalleryViewData: Sendable {
    enum GalleryState {
        case unknown
        case denied
        case loading
        case permitted(GalleryListViewData)
    }
    
    var state: GalleryState  = .unknown
}

@Observable
@MainActor
public class GalleryListViewData: Sendable {
    
    public var count: Int {
        items.count
    }
    
    public var items: [GalleryItemViewData] = []
    
}


public struct GalleryItemViewData: Identifiable, Sendable {
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


