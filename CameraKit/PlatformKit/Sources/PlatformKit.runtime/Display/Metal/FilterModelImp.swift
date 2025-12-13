//
//  FilterModelImp.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import Foundation
import CoreMedia
import CoreVideo
import CoreImage
import CoreKit


public class CIFilterModel : FilterModel {
    public let type: FilterType = .ciFilter
    public let contents: CIFilter
    
    public init(contents: CIFilter) {
        self.contents = contents
    }
}

public class MetalFilterModel : FilterModel {
    public let type: FilterType = .metalFilter
    public let contents: String
    
    public init(contents: String = "rosyEffect") {
        self.contents = contents
    }
    
}

public class EmptyFilterModel : FilterModel {
    public let type: FilterType = []
    public let contents: String = ""
    
    public init() {
        
    }
    
}
