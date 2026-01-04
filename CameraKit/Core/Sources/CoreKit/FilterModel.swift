//
//  FilterModel.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import Foundation

// Protocol for things with a title
public protocol TitledContent: Identifiable<String>, Sendable {
    var title: String { get }
}


public struct DisplayItem: TitledContent {
    public var id: String
    
    public let title: String
    
    public init(title: String, id: String) {
        self.title = title
        self.id = id
    }
}


