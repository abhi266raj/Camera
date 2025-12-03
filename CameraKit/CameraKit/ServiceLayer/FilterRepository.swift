//
//  FilterRepository.swift
//  CameraKit
//
//  Created by Abhiraj on 03/12/25.
//


import Foundation
import CoreImage

// MARK: - Domain

protocol FilterRepository {
    func fetchAll() async -> [FilterEntity]
}

// MARK: - DataSource

final class StaticFilterDataSource {
    func loadFilters() async -> [FilterEntity] {
        [
            FilterEntity(title: "Monochrome", model: CIFilterModel(contents: CIFilter(name: "CIColorMonochrome")!)),
            FilterEntity(title: "Metal", model: MetalFilterModel()),
            FilterEntity(title: "Green Effect", model: MetalFilterModel(contents: "greenEffect")),
            FilterEntity(title: "D2", model: MetalFilterModel(contents: "d2")),
            FilterEntity(title: "None", model: EmptyFilterModel())
        ]
    }
}

// MARK: - Repository Implementation

final class FilterRepositoryImpl: FilterRepository {
    private let dataSource: StaticFilterDataSource

    init(dataSource: StaticFilterDataSource = StaticFilterDataSource()) {
        self.dataSource = dataSource
    }

    func fetchAll() async -> [FilterEntity] {
        await dataSource.loadFilters()
    }
}
