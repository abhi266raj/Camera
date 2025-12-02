//
//  CameraActionBar.swift
//  CameraKit
//
//  Created by Abhiraj on 02/12/25.
//


import SwiftUI

struct CameraActionBar: View {
    let viewModel: CameraViewModel

    private let controlBackground = Color.black.opacity(0.35)

    var body: some View {
        HStack {
            Spacer()
            Button {
                Task { await viewModel.toggleCamera() }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(controlBackground)
                    .clipShape(Circle())
                    .padding(8)
            }
            .accessibilityLabel("Toggle Camera")
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}

#Preview {
    CameraActionBar(viewModel: CameraViewModel())
}
