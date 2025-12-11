//
//  CameraKitApp.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import SwiftUI

@main
struct CameraKitApp: App {
    @State var coordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
