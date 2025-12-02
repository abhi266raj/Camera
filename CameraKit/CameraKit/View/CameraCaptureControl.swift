//
//  CameraCaptureControl.swift
//  CameraKit
//
//  Created by Abhiraj on 02/12/25.
//

import SwiftUI

struct CameraCaptureControl: View {

    var viewModel: CameraViewModel

    private let controlSize: CGFloat = 56
    private let controlBackground = Color.black.opacity(0.35)

    init(viewModel: CameraViewModel = CameraViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 10) {
            switch viewModel.cameraOutputState {

            case .idle, .switching, .capturingPhoto:
                loadingView

            case .preview:
                if viewModel.showRecording {
                    startRecordingButton
                } else if viewModel.showCamera {
                    capturePhotoButton
                } else {
                    errorView("Unavailable")
                }

            case .recording:
                if viewModel.showRecording {
                    stopRecordingButton
                } else {
                    errorView("Recording Error")
                }
            }
        }
    }
}

// MARK: - Private reusable views
private extension CameraCaptureControl {

    var loadingView: some View {
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
    }

    func errorView(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(text)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .frame(height: controlSize)
        .background(controlBackground)
        .clipShape(Capsule())
        .accessibilityLabel(text)
    }

    var startRecordingButton: some View {
        Button {
            Task { try? await viewModel.performAction(action: .startRecord) }
        } label: {
            Image(systemName: "record.circle")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 34))
                .foregroundStyle(.red, .white)
                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                .background(controlBackground)
                .clipShape(Circle())
        }
        .accessibilityLabel("Start Recording")
    }

    var stopRecordingButton: some View {
        Button {
            Task { try? await viewModel.performAction(action: .stopRecord) }
        } label: {
            Image(systemName: "stop.circle")
                .font(.system(size: 34))
                .foregroundStyle(.white)
                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                .background(Color.red.opacity(0.9))
                .clipShape(Circle())
        }
        .accessibilityLabel("Stop Recording")
    }

    var capturePhotoButton: some View {
        Button {
            Task { try? await viewModel.performAction(action: .photo) }
        } label: {
            Image(systemName: "camera.circle")
                .font(.system(size: 34))
                .foregroundStyle(.white)
                .frame(width: controlSize * 1.1, height: controlSize * 1.1)
                .background(controlBackground)
                .clipShape(Circle())
        }
        .accessibilityLabel("Take Photo")
    }
}
