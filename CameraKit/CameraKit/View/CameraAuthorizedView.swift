import SwiftUI

struct CameraAuthorizedView: View {
    let viewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel

    var body: some View {
        ZStack {
            CameraPreview(cameraOutput: viewModel.getOutputView())
            VStack {
                Spacer()
                if viewModel.showFilter {
                    FilterListView(viewModel: filterListViewModel)
                }
                if viewModel.showCamera  {
                    Button("Click Photo") {
                        Task {
                            try? await viewModel.performAction(action: .photo)
                        }
                    }
                    .frame(height: 60)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)
                }
                HStack {
                    Button("Toggle") {
                        Task {
                             await viewModel.toggleCamera()
                        }
                    }
                    .frame(height: 60)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)

                    if viewModel.showRecording {
                        if viewModel.cameraOutputState == .rendering {
                            Button("Start Recording") {
                                Task {
                                    try? await viewModel.performAction(action: .startRecord)
                                }
                            }
                            .frame(height: 60)
                            .background(Color.black.opacity(0.2))
                            .foregroundColor(.white)

                        } else if viewModel.cameraOutputState == .recording {
                            Button("Stop Recording") {
                                Task {
                                    try? await viewModel.performAction(action: .stopRecord)
                                }
                            }
                            .frame(height: 60)
                            .background(Color.black.opacity(0.2))
                            .foregroundColor(.white)

                        } else if viewModel.cameraOutputState == .switching {
                            Button("Loading") {}
                                .frame(height: 60)
                                .background(Color.black.opacity(0.2))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CameraAuthorizedView(viewModel: CameraViewModel(), filterListViewModel: FilterListViewModel())
}
