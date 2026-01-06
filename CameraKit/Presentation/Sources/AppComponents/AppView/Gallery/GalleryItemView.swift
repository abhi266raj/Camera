//
//  GalleryItemView.swift
//  CameraKit
//
//  Created by Abhiraj on 05/01/26.
//

import SwiftUI
import AppViewModel

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



// MARK: - Preview

#Preview {
    let image =   "arrow.triangle.2.circlepath.camera"
    let viewData = GalleryItemViewData(imageName:image, id: "1")
    GalleryItemView(data: viewData) {
        
    }.frame(width: 200, height: 200).scaledToFit().border(.secondary,width: 1)
}
