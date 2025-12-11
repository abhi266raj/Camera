//
//  for.swift
//  FeatureKit
//
//  Created by Abhiraj on 11/12/25.
//


// Base protocol for a view model providing view data
public protocol ContentViewModel {
    associatedtype ViewData
    var viewData: ViewData { get }
}

// View model supporting a typed action triggered by the view
public protocol ActionableViewModel: ContentViewModel {
    associatedtype ViewAction
    func trigger(_ action: ViewAction)
}
