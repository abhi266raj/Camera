//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import CoreKit

public protocol CameraProccessor<ConnectionType>: class, ContentConnection{
    var selectedFilter: (any FilterModel)? {get set}
}


protocol ChainedProcessor {
    associatedtype Element
    associatedtype NextProcessor: ChainedProcessor = Self
    var next: NextProcessor? { get set }
    func process(_ element: Element)
}

