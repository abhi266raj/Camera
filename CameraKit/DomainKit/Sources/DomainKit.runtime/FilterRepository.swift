//
//  FilterRepository.swift
//  CameraKit
//
//  Created by Abhiraj on 03/12/25.
//


import Foundation
import CoreImage
import CoreKit
import PlatformKit_runtime
import DomainKit_api

// MARK: - DataSource

final public class StaticFilterDataSource {
    
    public init() {
        
    }
    public func loadFilters() async -> [FilterEntity] {
        [
            FilterEntity(title: "Monochrome", model: CIFilterModel(contents: CIFilter(name: "CIColorMonochrome")!)),
            FilterEntity(title: "Metal", model: MetalFilterModel()),
            FilterEntity(title: "Four Quadrant Effect", model: MetalFilterModel(contents: "fourQuadrantEffect")),
            FilterEntity(title: "Green Effect", model: MetalFilterModel(contents: "greenEffect")),
            FilterEntity(title: "D2", model: MetalFilterModel(contents: "d2")),
            FilterEntity(title: "None", model: EmptyFilterModel())
        ]
    }
}

// MARK: - Repository Implementation

final public class FilterRepositoryImpl: FilterRepository {
    private let dataSource: StaticFilterDataSource

    public init(dataSource: StaticFilterDataSource = StaticFilterDataSource()) {
        self.dataSource = dataSource
    }

    public func fetchAll() async -> [FilterEntity] {
        await dataSource.loadFilters()
    }
}
