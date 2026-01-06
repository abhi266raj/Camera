//
//  GalleryItemView.swift
//  CameraKit
//
//  Created by Abhiraj on 05/01/26.
//

import SwiftUI

struct GalleryItemView: View {
    let data: GalleryItemViewData
    let loadAction: (() async -> Void)?
    var body: some View {
        ZStack {
            if let image = data.image {
                    image
                    .resizable()
                    // .aspectRatio(contentMode: .fit)
            } else if data.isLoading {
                LoadingView()
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            } else {
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            }
        }
        .task(priority: .background) {
            if data.image == nil {
                await loadAction?()
            }
        }
        .clipped()
    }
       
}


public struct GalleryItemViewData:Identifiable, Equatable, Sendable {
    let image: Image?
    let isLoading: Bool
    public let id:String
    
    init(image: UIImage? = nil, isLoading: Bool = false, id:String) {
        if let image {
            self.image = Image(uiImage: image)
        }else {
            self.image = nil
        }
        self.isLoading = false
        self.id = id
    }
    
    init(imageName: String, isLoading: Bool = false, id:String) {
        self.isLoading = false
        self.id = id
        self.image = Image(systemName: imageName)
        
    }
    
}

// MARK: - Preview

#Preview {
    let image =   "arrow.triangle.2.circlepath.camera"
    let viewData = GalleryItemViewData(imageName:image, id: "1")
    GalleryItemView(data: viewData) {
        
    }.frame(width: 200, height: 200).scaledToFit().border(.secondary,width: 1)
}
