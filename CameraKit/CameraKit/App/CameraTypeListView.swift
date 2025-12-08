import SwiftUI
import CoreKit

@Observable
public class CameraTypeListViewModel {
    init() {
        self.cameraTypes = CameraType.allCases
    }
    var cameraTypes: [CameraType]
}

extension CameraType {
    var title: String {
        switch self {
        case .camera: return "Camera"
        case .basicPhoto: return "Photo Camera"
        case .basicVideo: return "Video Camera"
        case .metal: return "Filtered (Metal) Camera"
        }
    }
}

public struct CameraTypeListView: View {
    @State private var viewModel: CameraTypeListViewModel
    
    public init(viewModel: CameraTypeListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            List(viewModel.cameraTypes) { type in
                NavigationLink(value: type) {
                    Text(type.title)
                }
            }
            .navigationTitle("Camera Types")
            .navigationDestination(for: CameraType.self) { type in
                CameraCoordinator().createView(cameraType: type)
                    .navigationTitle(type.title)
            }
        }
    }
}
