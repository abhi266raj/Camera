//
//  FilterModelSelectionStreamImpl.swift
//  CameraKit
//
//  Created by Abhiraj on 26/12/25.
//

import PlatformApi

public struct FilterModelSelectionStreamImpl: FilterModelSelectionStream {
    private let continuation: AsyncStream<FilterModel>.Continuation
    public let selectionStream: AsyncStream<FilterModel>
    
    public init() {
        var tempContinuation: AsyncStream<FilterModel>.Continuation!
        self.selectionStream = AsyncStream { cont in
            tempContinuation = cont
        }
        self.continuation = tempContinuation
    }
    
    public func send(model: FilterModel) {
        continuation.yield(model)
    }
}
