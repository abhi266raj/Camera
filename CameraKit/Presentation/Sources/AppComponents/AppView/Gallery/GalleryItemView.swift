//
//  GalleryItemView.swift
//  CameraKit
//
//  Created by Abhiraj on 05/01/26.
//

import SwiftUI
import AppViewModel

public struct GalleryItemView: View {
    let data: GalleryItemViewData
    let loadAction: (() async -> Void)?
    
    public init(data: GalleryItemViewData, loadAction: (() async -> Void)?) {
        self.data = data
        self.loadAction = loadAction
    }
    
    public var body: some View {
        ZStack {
            if let image = data.image {
                    image
                    .resizable()
                    .scaledToFit()
                    // .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
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
