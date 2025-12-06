import SwiftUI

struct CameraLoadingView: View {
    let viewModel: CameraViewModel

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    //CameraLoadingView(viewModel: CameraViewModel())
}
