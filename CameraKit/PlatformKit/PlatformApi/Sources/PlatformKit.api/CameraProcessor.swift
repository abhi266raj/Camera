//
//  CameraProcessor.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import CoreMedia
import CoreKit

public protocol CameraProccessor: class {
    func setup(connection: ContentConnection)
    var selectedFilter: (any FilterModel)? {get set}
}

public protocol FilterSelectionDelegate: AnyObject {
    func didUpdateSelection(_ filter: FilterModel?)
}


protocol ChainedProcessor {
    associatedtype Element
    associatedtype NextProcessor: ChainedProcessor = Self
    var next: NextProcessor? { get set }
    func process(_ element: Element)
}

