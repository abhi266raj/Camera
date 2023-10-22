//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI

struct ContentView: View {
    
    var viewModel: CameraManager = CameraManager()
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
                    CameraPreview(cameraOutput: viewModel.cameraInputManger.output)
//                    Button("Adjust") {
//                        viewModel.cameraInputManger.output.updateFrame()
//                    }.frame(height: 60)
                    VStack {
                        Spacer()
                        HStack {
                            Button("Toggle") {
                                Task {
                                     await viewModel.cameraInputManger.input.toggleCamera()
                                }
                                
                            }.frame(height: 60)
                                .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                .foregroundColor(.white)
                            if viewModel.cameraInputManger.output.outputState == .rendering {
                                Button("Start Recording") {
                                    Task {
                                        try? await viewModel.cameraInputManger.output.performAction(action: .startRecord)
                                    }
                                }.frame(height: 60)
                                    .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                    .foregroundColor(.white)
                                
                            } else if viewModel.cameraInputManger.output.outputState == .recording {
                                Button("Stop Recording") {
                                    Task {
                                        try? await viewModel.cameraInputManger.output.performAction(action: .stopRecord)
                                    }
                                }.frame(height: 60)
                                    .background(Color.black.opacity(0.2)) // Set the background color to black with alpha 0.2
                                    .foregroundColor(.white)
                                
                            } else if viewModel.cameraInputManger.output.outputState == .switching {
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
    let cameraOutput: any CameraOutput

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
