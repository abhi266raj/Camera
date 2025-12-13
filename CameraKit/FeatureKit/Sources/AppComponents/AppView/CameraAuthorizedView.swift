import SwiftUI
import PlatformKit_runtime
import AppViewModel

struct CameraAuthorizedView: View {
    let viewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel

    var body: some View {
        ZStack {
            
            if let cameraDisplayOutput = viewModel.getOutputView() {
                CameraPreview(cameraOutput: cameraDisplayOutput)
                    .ignoresSafeArea()
            }else {
                CameraFeedViewer(viewModel: viewModel)
            }
           

            VStack() {
                // Top bar with switch at top-right
                HStack {
                    Spacer()
                    CameraActionBar(viewModel: viewModel)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()

                if viewModel.showFilter {
                    FilterListView(viewModel: filterListViewModel)
                        .padding(.bottom)
                }
                
                HStack {
                    Spacer()
                    CameraCaptureControl(viewModel: viewModel)
                        .padding(.bottom, 16)
                    Spacer()
                }
            }
        }
    }
}

