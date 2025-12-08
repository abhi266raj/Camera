//
//  CameraActionBar.swift
//  CameraKit
//
//  Created by Abhiraj on 02/12/25.
//

import SwiftUI
import AppViewModel

struct CameraActionBar: View {
    let viewModel: CameraViewModel

    private let controlBackground = Color.black.opacity(0.35)

    var body: some View {
        HStack(spacing: 6) {
            Button {
                Task { await viewModel.toggleCamera() }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Toggle Camera")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
