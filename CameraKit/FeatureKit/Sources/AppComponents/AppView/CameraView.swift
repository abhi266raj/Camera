//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI
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
            switch viewModel.viewData.cameraPermissionState {
            case .unknown:
                LoadingView()
            case .denied:
                CameraDeniedView()
            case .authorized:
                CameraAuthorizedView(viewModel: viewModel, filterListViewModel: filterListViewModel)
                    .onAppear(perform: {
                        viewModel.trigger(.setup)
                    })
            }
        }
        
        .onAppear(perform: {
            viewModel.trigger(.permissionSetup)
        })
        .padding()
    }

}



