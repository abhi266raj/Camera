import SwiftUI

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

struct CameraTypeListView: View {
    var body: some View {
        NavigationStack {
            List(CameraType.allCases) { type in
                NavigationLink(value: type) {
                    Text(type.title)
                }
            }
            .navigationTitle("Camera Types")
            .navigationDestination(for: CameraType.self) { type in
                CameraCoordinator().createView(cameraType: type)
                    .navigationTitle(type.title)
//                }
            }
        }
    }
}
