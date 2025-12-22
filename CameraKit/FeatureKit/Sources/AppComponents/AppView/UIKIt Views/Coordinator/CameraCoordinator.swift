//
//  CameraCoordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 21/12/25.
//

import AppViewModel
import SwiftUI

final public class CameraCoordinator: Identifiable, Hashable, Equatable {
    
    public var id:String = UUID().uuidString
    
    public static func == (lhs: CameraCoordinator, rhs: CameraCoordinator) -> Bool {
          lhs.id == rhs.id
      }

     public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
    }

    let viewModelProvider: CameraViewModelFactory
    
    @MainActor
    public lazy var cameraView: some View = {
        makeCameraView()
    }()

    public init(viewModelProvider: CameraViewModelFactory) {
        self.viewModelProvider = viewModelProvider
    }
    
    @MainActor
    private func makeCameraView() -> some View {
            let cameraViewModel = self.viewModelProvider.cameraViewModel()
            let filterVM =  self.viewModelProvider.filterViewModel()
            return CameraView(viewModel: cameraViewModel, filterListViewModel: filterVM).task {
                await filterVM.activate()
            }
    }
}

