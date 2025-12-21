//
//  ContentView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI
import AppViewModel
import CoreKit


@Observable final class CameraContentViewData: Sendable {
    let cameraData: CameraViewData
    let filterData: FilterListViewData
    
    init(cameraData: CameraViewData, filterData: FilterListViewData) {
        self.cameraData = cameraData
        self.filterData = filterData
    }
}

struct CameraContentAction {
    var cameraAction: (CameraViewAction) -> Void
    var filterAction: (FilterAction) -> Void
    
}

public struct CameraView: View {
    @State var viewModel: CameraViewModel
    @State var filterListViewModel: FilterListViewModel
    @State var viewAction: CameraContentAction
    @State var viewData: CameraContentViewData
    
    public init(viewModel: CameraViewModel, filterListViewModel: FilterListViewModel) {
        self.viewModel = viewModel
        self.filterListViewModel = filterListViewModel
        
        viewAction = CameraContentAction(cameraAction: { action in
            viewModel.trigger(action)
        }, filterAction: { filterAction in
            filterListViewModel.trigger(filterAction)
        })
        
        viewData = CameraContentViewData(cameraData:viewModel.viewData, filterData:filterListViewModel.viewData)
    }
    
    public var body: some View {
        VStack {
            switch viewData.cameraData.cameraPermissionState {
            case .unknown:
                LoadingView()
            case .denied:
                CameraDeniedView()
            case .authorized:
                Group {
                    if viewData.cameraData.cameraPhase == .paused {
                        Text ("Paused")
                    }else if viewData.cameraData.cameraPhase == .inactive {
                        Text("Setup")
                        LoadingView()
                    }else {
                        CameraAuthorizedView(viewData: viewData, viewAction: viewAction)
                    }
                }.onAppear{ viewAction.cameraAction(.setup)}
                
            }
        }.aspectRatio(0.5, contentMode: .fit)
        .padding()
        .onAppear{viewAction.cameraAction(.permissionSetup)}
        .onDisappear{ viewAction.cameraAction(.pause)}
    }

}



