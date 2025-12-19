import SwiftUI
import AppViewModel

struct CameraAuthorizedView: View {
    let viewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel

    var body: some View {
        ZStack {
            
            if viewModel.viewData.showFilter {
                    CameraMetalViewer(viewModel: viewModel)
            }else if viewModel.viewData.showMultiCam {
                    DualCameraViewer(viewModel: viewModel)
                }else {
                    CameraFeedViewer(viewModel: viewModel)
                }
    
            VStack() {
                HStack {
                    Spacer()
                    CameraActionBar(viewModel: viewModel)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()

                if viewModel.viewData.showFilter {
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

