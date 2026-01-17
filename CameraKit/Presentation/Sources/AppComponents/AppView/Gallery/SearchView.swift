//
//  SearchView.swift
//  CameraKit
//
//  Created by Abhiraj on 17/01/26.
//


import SwiftUI
import AppViewModel

// MARK: - View

public struct SearchView: View {
    @State private var query = ""
    private let action: ViewAction<String>

    public init(action: ViewAction<String>) {
        self.action = action
    }

    public var body: some View {
            TextField("Search", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()
        .onChange(of: query) { value in
            Task {
                await action.execute(value)
            }
        }
    }
}
