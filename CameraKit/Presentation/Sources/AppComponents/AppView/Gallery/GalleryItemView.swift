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
            switch data.content {
            case .idle:
                LoadingView()
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            case .loading:
                LoadingView()
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            case .loaded(let image):
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipped()

                    if data.isVideo {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundStyle(.white)
                            .opacity(0.85)
                            .shadow(radius: 6)
                    }
                }
                
            case .error:
                LoadingView()
            }
            
        }
        .task(priority: .background) {
            if data.content == .idle {
                await loadAction?()
            }
        }
        .clipped()
    }
       
}



// MARK: - Preview

#Preview {
    let image =   "arrow.triangle.2.circlepath.camera"
    let viewData = GalleryItemViewData(imageName:image, id: "1", isVideo: false)
    GalleryItemView(data: viewData) {
        
    }.frame(width: 200, height: 200).scaledToFit().border(.secondary,width: 1)
}
