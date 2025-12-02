import SwiftUI

struct CameraAuthorizedView: View {
    let viewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel

    // MARK: - Styling
    private let controlSize: CGFloat = 56
    private let controlBackground = Color.black.opacity(0.35)

    var body: some View {
        ZStack {
            CameraPreview(cameraOutput: viewModel.getOutputView())
                .ignoresSafeArea()

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

                // Bottom centered primary control
                bottomCenterControls
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Bottom Center Controls
    private var bottomCenterControls: some View {
        VStack(spacing: 10) {
            if viewModel.showRecording {
                // Unified loader for idle and switching
                switch viewModel.cameraOutputState {
                case .idle, .switching:
                    HStack(spacing: 8) {
                        ProgressView().tint(.white)
                        Text("Preparing…")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: controlSize)
                    .background(controlBackground)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preparing Camera")
                default:
                    EmptyView()
                }
            }

            // Primary action
            Group {
                switch viewModel.cameraOutputState {
                case .recording:
                    if viewModel.showRecording {
                        Button(action: {
                            Task { try? await viewModel.performAction(action: .stopRecord) }
                        }) {
                            Image(systemName: "stop.circle")
                                .font(.system(size: 34, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                                .background(Color.red.opacity(0.9))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Stop Recording")
                    }
                case .rendering:
                    if viewModel.showRecording {
                        Button(action: {
                            Task { try? await viewModel.performAction(action: .startRecord) }
                        }) {
                            Image(systemName: "record.circle")
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 34, weight: .regular))
                                .foregroundStyle(.red, .white)
                                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                                .background(controlBackground)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Start Recording")
                    } else if viewModel.showCamera {
                        Button(action: {
                            Task { try? await viewModel.performAction(action: .photo) }
                        }) {
                            Image(systemName: "camera.circle")
                                .font(.system(size: 34, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                                .background(controlBackground)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Take Photo")
                    }
                case .idle, .switching:
                    // No primary button while preparing
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    CameraAuthorizedView(viewModel: CameraViewModel(), filterListViewModel: FilterListViewModel())
}
