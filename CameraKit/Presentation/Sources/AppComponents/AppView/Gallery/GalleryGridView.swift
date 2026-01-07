import SwiftUI
import AppViewModel

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
        .task(priority:.high) {
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



// MARK: - Thumbnail View


// MARK: - Preview

#Preview {
    // GalleryGridView()
}
