import SwiftUI
import Photos
import Observation

// MARK: - View

public struct GalleryGridView: ConfigurableView, ContentView {
    
    let config: GalleryViewConfig
        
    public init(viewData: GalleryListViewData, config: GalleryViewConfig) {
        self.viewData = viewData
        self.config = config
    }
    
    let viewData: GalleryListViewData
    
    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 400), spacing: 30)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                Spacer(minLength: 40)
                HStack {
                    Spacer(minLength: 30)
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewData.items, id: \.id) { data in
                            GalleryItemView(data: data, loadAction: {
                                await config.onItemLoad(data)
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                           
                            
                            
                            
                        }
                    }
                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("Gallery")
        }
        .task(priority:.utility) {
             await config.onLoad()
        }
    }
}

public struct GalleryViewConfig {
    
    public init(onLoad: @escaping () async -> Void, onItemLoad: @escaping (GalleryItemViewData) async -> Void) {
        self.onLoad = onLoad
        self.onItemLoad = onItemLoad
    }
    
    var onLoad: () async -> Void
    var onItemLoad: (GalleryItemViewData) async-> Void
}


@Observable
@MainActor
public class GalleryListViewData {
    
    var count: Int {
        items.count
    }
    
    var items: [GalleryItemViewData] = []
    
}

// MARK: - ViewModel


public final class GalleryViewModel  {
    @MainActor var  items: [PHAsset] = []
    @MainActor public let viewData: GalleryListViewData = GalleryListViewData()
    
    @MainActor
    public init() {
        
    }

    @MainActor
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
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: options)
        items = result.objects(at: IndexSet(integersIn: 0..<result.count))
        await updateViewData()
    }
    
    @MainActor
    func updateViewData() {
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

// MARK: - Thumbnail View


// MARK: - Preview

#Preview {
    // GalleryGridView()
}
