import SwiftUI
import Photos
import Observation

// MARK: - View

public struct GalleryGridView: View {
    
    public init() {
        
    }
    @State private var viewModel = GalleryViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 200), spacing: 8)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                        GalleryThumbnailView(asset: asset)
                            .frame(width: 100, height: 100) 
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            
                            //.frame(height: 100)
                    }
                }
            }
            .navigationTitle("Gallery")
        }
        .task(priority:.utility) {
            await viewModel.load()
        }
    }
}

// MARK: - ViewModel

@Observable
final class GalleryViewModel: @unchecked Sendable  {
    var assets: [PHAsset] = []

    func load() async {
        var status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        if status == .authorized || status == .limited {
            fetchAssets()
        }
    }

    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: options)
        assets = result.objects(at: IndexSet(integersIn: 0..<result.count))
    }
}

// MARK: - Thumbnail View

struct GalleryThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                LoadingView()
                Rectangle()
                    .fill(.secondary.opacity(0.2))
            }
        }
        .task(id: asset.localIdentifier, priority:.background) {
            await loadThumbnail()
        }
        .clipped()
    }
    
    private func loadThumbnail() async {
        let manager = PHImageManager.default()
        let size = CGSize(width: 900, height:900)
        
        var didResume = false
        
        image = await withCheckedContinuation { continuation in
            manager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                guard !didResume else { return }
                didResume = true
                continuation.resume(returning: image)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GalleryGridView()
}
