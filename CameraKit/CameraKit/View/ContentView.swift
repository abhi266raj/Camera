//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI

struct ContentView: View {
    
    var viewModel: CameraViewModel = CameraViewModel()
    var body: some View {
        VStack {
            switch viewModel.state {
            case .unknown:
                Text("Loading")
               // CameraPreview(cameraOutput: viewModel.cameraInputManger.output)
            case .permissionDenied:
                Text("Permission Denied")
            case .active:
                ZStack {
                    CameraPreview(cameraOutput: viewModel.getOutputView())
                    VStack {
                        Spacer()
                        FilterListView { selection in
                            viewModel.updateSelection(filter: selection)
                        }
                        HStack {
                            Button("Toggle") {
                                Task {
                                     await viewModel.toggleCamera()
                                }
                                
                            }.frame(height: 60)
                                .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                .foregroundColor(.white)
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
                
            case .paused:
                Text("Paused")
                
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
    ContentView()
}


struct CameraPreview: UIViewRepresentable {
    let cameraOutput: any CameraOutputService

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
