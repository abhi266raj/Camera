//
//  FilterType.swift
//  CameraKit
//
//  Created by Abhiraj on 17/12/25.
//



public struct FilterType: OptionSet, Sendable {
    
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