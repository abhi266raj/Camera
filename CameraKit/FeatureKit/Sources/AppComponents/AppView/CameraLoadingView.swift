import SwiftUI
import AppViewModel

struct LoadingView: View {
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    LoadingView()
}
