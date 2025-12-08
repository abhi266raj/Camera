import SwiftUI
import CoreKit
import AppViewModel

public struct CameraTypeListView: View {
    @State private var viewModel: CameraTypeListViewModel
    
    public init(viewModel: CameraTypeListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List(viewModel.cameraTypes) { type in
            Button(type.title) {
                viewModel.didSelect(camera:type)
            }
        }
    }
}
