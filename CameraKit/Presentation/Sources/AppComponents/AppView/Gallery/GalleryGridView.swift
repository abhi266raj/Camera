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
    
    static let spacing: CGFloat = 10
    
    //    private let columns = [
    //        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 10)
    ////        GridItem(.fixed(300), spacing: 10),
    ////        GridItem(.fixed(300), spacing: 10),
    ////        GridItem(.fixed(300), spacing: 10),
    ////        GridItem(.fixed(300), spacing: 10),
    //    ]
    
    public var body: some View {
        NavigationStack {
            GeometryReader {item in
                let width = item.size.width/4 - 2*Self.spacing
                let column = [GridItem(.adaptive(minimum: width, maximum: width * 2), spacing: Self.spacing)]
                
                ScrollView {
                    Spacer(minLength: 10)
                    HStack {
                        Spacer(minLength: 30)
                        
                        
                        LazyVGrid(columns: column, alignment: .leading, spacing: 16) {
                            ForEach(viewData.items, id: \.id) { data in
                                VStack {
                                    HStack {
                                        GalleryItemView(data: data, loadAction: {
                                            await config.onItemLoad(data)
                                        }).onTapGesture {
                                            Task {
                                                await config.onItemTap(data)
                                            }
                                        }
                                        .background(.red)
                                        .scaledToFill()
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    
                                    
                                }
                                .background(.green)
                                .frame(width: width, height: width)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .clipped()
                            }
                        }
                    }
                    //    }
                    
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
    
    public init(onLoad: @escaping () async -> Void, onItemLoad: @escaping (GalleryItemViewData) async -> Void, onItemTap: @escaping (GalleryItemViewData) async -> Void) {
        self.onLoad = onLoad
        self.onItemLoad = onItemLoad
        self.onItemTap = onItemTap
    }
    
    var onLoad: () async -> Void
    var onItemLoad: (GalleryItemViewData) async-> Void
    var onItemTap: (GalleryItemViewData) async-> Void
}



// MARK: - Thumbnail View


// MARK: - Preview

#Preview {
    // GalleryGridView()
}
