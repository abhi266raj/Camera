//
//  VMView.swift
//  FeatureKit
//
//  Created by Abhiraj on 11/12/25.
//

import SwiftUI

// Base protocol: a view displaying some content
protocol ContentView: View {
    associatedtype ViewData
    var viewData: ViewData { get }
}

protocol ConfigurableView: View {
    associatedtype ViewConfig
    var config: ViewConfig { get }
    
}

// View with a simple no-parameter action
protocol ActionableView: ContentView {
    var onAction: () -> Void { get }
}

// View with one or more typed actions
protocol MultiActionableView: ContentView {
    associatedtype Action
    var onAction: (Action) -> Void { get }
}
