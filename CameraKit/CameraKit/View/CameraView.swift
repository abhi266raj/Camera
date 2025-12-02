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
                Text("Loading")
               // CameraPreview(cameraOutput: viewModel.cameraInputManger.output)
            case .denied:
                Text("Permission Denied")
            case .authorized:
                ZStack {
                    CameraPreview(cameraOutput: viewModel.getOutputView())
                    VStack {
                        Spacer()
                        if viewModel.showFilter {
                            FilterListView(viewModel: filterListViewModel)
                        }
                        if viewModel.showCamera  {
                            Button("Click Photo") {
                                Task {
                                    try? await viewModel.performAction(action: .photo)
                                }
                            }.frame(height: 60)
                                .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                .foregroundColor(.white)
                        }
                        HStack {
                            Button("Toggle") {
                                Task {
                                     await viewModel.toggleCamera()
                                }
                                
                            }.frame(height: 60)
                                .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                .foregroundColor(.white)
                            if viewModel.showRecording {
                                if viewModel.cameraOutputState == .rendering {
                                    Button("Start Recording") {
                                        Task {
                                            try? await viewModel.performAction(action: .startRecord)
                                        }
                                    }.frame(height: 60)
                                        .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                        .foregroundColor(.white)
                                    
                                } else if viewModel.cameraOutputState == .recording {
                                    Button("Stop Recording") {
                                        Task {
                                            try? await viewModel.performAction(action: .stopRecord)
                                        }
                                    }.frame(height: 60)
                                        .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                        .foregroundColor(.white)
                                    
                                } else if viewModel.cameraOutputState == .switching {
                                    Button("Loading") {}.frame(height: 60)
                                        .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
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
