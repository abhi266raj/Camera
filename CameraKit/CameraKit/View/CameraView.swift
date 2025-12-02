//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI

struct CameraView: View {
    let viewModel: CameraViewModel
    let filterListViewModel: FilterListViewModel
    
    init(viewModel: CameraViewModel = CameraViewModel(), filterListViewModel: FilterListViewModel = FilterListViewModel()) {
        self.viewModel = viewModel
        self.filterListViewModel = filterListViewModel
    }
    
    var body: some View {
        VStack {
            switch viewModel.cameraPermissionState {
            case .unknown:
                CameraLoadingView(viewModel: viewModel)
            case .denied:
                CameraDeniedView()
            case .authorized:
                CameraAuthorizedView(viewModel: viewModel, filterListViewModel: filterListViewModel)
            }
        }
        .onAppear(perform: {
            Task.detached(priority: .userInitiated)  {
                await viewModel.setup()
            }
        })
        .padding()
    }

}

#Preview {
    CameraView()
}


struct CameraPreview: UIViewRepresentable {
    let cameraOutput: any CameraContentPreviewService

    func makeUIView(context: Context) -> UIView {
        let view =  cameraOutput.previewView
        view.backgroundColor = .gray
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        cameraOutput.updateFrame()
        
        // Update the view if needed
    }
}
