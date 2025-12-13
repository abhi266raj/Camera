//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI
import PlatformKit_api
import AppViewModel

public struct CameraView: View {
    @State var viewModel: CameraViewModel
    @State var filterListViewModel: FilterListViewModel
    
    public init(viewModel: CameraViewModel, filterListViewModel: FilterListViewModel) {
        self.viewModel = viewModel
        self.filterListViewModel = filterListViewModel
    }
    
    public var body: some View {
        VStack {
            switch viewModel.cameraPermissionState {
            case .unknown:
                LoadingView()
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


struct CameraPreview: UIViewRepresentable {
    let cameraOutput: any CameraDisplayOutput

    func makeUIView(context: Context) -> UIView {
        let view =  cameraOutput.previewView
        view.backgroundColor = .gray
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        cameraOutput.updateFrame()
    }
}
