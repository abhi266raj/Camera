//
//  FilterModelImp.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

@preconcurrency import CoreImage.CIImage
import CoreKit


public struct CIFilterModel : Sendable, FilterModel {
    public let type: FilterType = .ciFilter
    public let contents: CIFilter
    
    public init(contents: CIFilter) {
        self.contents = contents
    }
}

public struct MetalFilterModel : FilterModel, Sendable {
    public let type: FilterType = .metalFilter
    public let contents: String
    
    public init(contents: String = "rosyEffect") {
        self.contents = contents
    }
    
}

public struct EmptyFilterModel : FilterModel {
    public let type: FilterType = []
    public let contents: String = ""
    
    public init() {
        
    }
    
}

