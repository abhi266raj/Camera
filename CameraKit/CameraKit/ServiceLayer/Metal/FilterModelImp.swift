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


class CIFilterModel : FilterModel {
    let type: FilterType = .ciFilter
    let contents: CIFilter
    
    init(contents: CIFilter) {
        self.contents = contents
    }
}

class MetalFilterModel : FilterModel {
    let type: FilterType = .metalFilter
    let contents: String = ""
    
}

class EmptyFilterModel : FilterModel {
    let type: FilterType = []
    let contents: String = ""
    
}
