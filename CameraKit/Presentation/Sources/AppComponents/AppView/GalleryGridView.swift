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
                    ForEach(viewModel.viewData, id: \.id) { data in
                        GalleryItemView(data: data, loadAction: {
                             await viewModel.loadThumbnail(id: data.id)
                        })
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
final class GalleryViewModel  {
    var items: [PHAsset] = []
    @MainActor var viewData: [GalleryItemViewData] = []
    
    init() {
        
    }

    @MainActor func load() async {
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
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: options)
        items = result.objects(at: IndexSet(integersIn: 0..<result.count))
        updateViewData()
    }
    
    @MainActor
    func updateViewData() {
        viewData = items.map{GalleryItemViewData(id: $0.localIdentifier)}
    }
    
    @MainActor
    func loadThumbnail(id: String) async  {
        guard let index =  viewData.firstIndex(where: { $0.id == id}) else {
            return
        }
        if viewData[index].isLoading  {
            return
        }
        await viewData[index] = .init(isLoading: true, id: id)
        let asset = items[index]
        let manager = PHImageManager.default()
        let size = CGSize(width: 900, height: 900)
        var didResume = false
        let image = await withCheckedContinuation { continuation in
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
        await viewData[index] = .init(image: image, id: id)
    }
}

// MARK: - Thumbnail View

struct GalleryItemViewData:Identifiable, Equatable {
    let image: UIImage?
    let isLoading: Bool
    let id:String
    
    init(image: UIImage? = nil, isLoading: Bool = false, id:String) {
        self.image = image
        self.isLoading = false
        self.id = id
    }
}

struct GalleryItemView: View {
    let data: GalleryItemViewData
    let loadAction: (() async -> Void)?
    var body: some View {
        ZStack {
            if let image = data.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
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
    GalleryGridView()
}
