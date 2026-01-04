import SwiftUI
import CoreKit
import AppViewModel

public struct CameraTypeListView: MultiActionableView {
    
    var viewData: [CameraType]
    var onAction: (CameraType) -> Void

    public init(viewData: [CameraType], action: @escaping (CameraType) -> Void) {
        self.viewData = viewData
        self.onAction = action
    }

    public var body: some View {
        List(viewData) { type in
            Button(action: {
                onAction(type)
            }) {
                HStack {
                    Text(type.title)
                        .foregroundColor(.primary)
                    Spacer()   // makes the row fill horizontally
                }
                .contentShape(Rectangle()) // ensures the tap area is the whole row
            }
            .buttonStyle(PlainButtonStyle()) // disables default button styling
        }
    }
}

#Preview {
    CameraTypeListView(viewData: [.multicam]) { _ in
    }
}
