//
//  for.swift
//  FeatureKit
//
//  Created by Abhiraj on 11/12/25.
//


// Base protocol for a view model providing view data
public protocol ContentViewModel {
    associatedtype ViewData
    @MainActor
    var viewData: ViewData { get }
}

// View model supporting a typed action triggered by the view
public protocol ActionableViewModel: ContentViewModel {
    associatedtype ViewAction
    func trigger(_ action: ViewAction)
}


public enum LoadableError: Error {
    case permissionDenied
    case temporary
    case permanent
    case unknown
}


public enum Loadable<T>{
    case idle
    case loading
    case error(LoadableError)
    case loaded(T)
}

extension LoadableError: Sendable { }
extension Loadable: Equatable where T: Equatable {}
extension Loadable: Sendable where T: Sendable {}

