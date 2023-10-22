//
//  FilterModel.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import Foundation


public struct FilterType: OptionSet {
    
   
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let ciFilter = FilterType(rawValue: 1 << 0)
    public static let metalFilter = FilterType(rawValue: 1 << 1)
   
}

public protocol FilterModel {
    associatedtype Filter
    var type: FilterType {get}
    var contents: Filter {get}
}

