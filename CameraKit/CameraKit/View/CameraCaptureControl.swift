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

    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 10) {
            switch viewModel.cameraPhase {

            case .inactive, .paused, .switching:
                loadingView
                
            case .active(let mode):
                switch mode {
                case .preview:
                    if viewModel.showRecording {
                        startRecordingButton
                    } else if viewModel.showCamera {
                        capturePhotoButton
                    } else {
                        errorView("Unavailable")
                    }
                case .initiatingCapture:
                    loadingView
                case .capture(let type):
                    switch type {
                    case .photo:
                        loadingView
                    case .video:
                        stopRecordingButton
                    }

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
            ZStack {
                // Outer white ring (iOS-style record button ring)
                Circle()
                    .stroke(lineWidth: controlSize * 0.08)
                    .foregroundStyle(.white)
                    .frame(width: controlSize, height: controlSize)

                // Inner solid red circle
                Circle()
                    .fill(.red)
                    .frame(width: controlSize * 0.70, height: controlSize * 0.70)
                    .shadow(radius: 2)
            }
        }
        .accessibilityLabel("Start Recording")
    }

    var stopRecordingButton: some View {
        Button {
            Task { try? await viewModel.performAction(action: .stopRecord) }
        } label: {
            ZStack {
                // Outer red ring
                Circle()
                    .stroke(lineWidth: controlSize * 0.08)
                    .foregroundStyle(.red)
                    .frame(width: controlSize, height: controlSize)

                // Inner white square (stop symbol)
                RoundedRectangle(cornerRadius: controlSize * 0.06, style: .continuous)
                    .fill(.white)
                    .frame(width: controlSize * 0.55, height: controlSize * 0.55)
                    .shadow(radius: 2)
            }
            
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
