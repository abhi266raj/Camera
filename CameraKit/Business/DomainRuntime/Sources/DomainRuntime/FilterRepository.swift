//
//  FilterRepository.swift
//  CameraKit
//
//  Created by Abhiraj on 03/12/25.
//

internal import CoreImage
import CoreKit
import PlatformApi
import DomainApi
internal import Synchronization

// MARK: - DataSource


struct FilterEntity {
    public let title: String
    public let model: any FilterModel
    public let id: String = UUID().uuidString

    public init(title: String, model: any FilterModel) {
        self.title = title
        self.model = model
    }
}


extension FilterEntity: TitledContent {
    
}

final public class StaticFilterDataSource: Sendable {
    
    public init() {
        
    }
    

     func loadFilter() async -> [FilterEntity] {
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


// MARK: - Domain

protocol FilterRepository: Sendable {
    func fetchAll() async -> [TitledContent]
    func filter(id: String) async -> FilterModel?
}

final class FilterRepositoryImpl: FilterRepository {
    private let dataSource: StaticFilterDataSource
    private let filterMaps = Mutex<[String: FilterModel]>([:])

    init(dataSource: StaticFilterDataSource = StaticFilterDataSource()) {
        self.dataSource = dataSource
    }

    func fetchAll() async -> [TitledContent] {
        let list = await dataSource.loadFilter()
        list.forEach { entity in
            filterMaps.withLock { filterMap in
                filterMap[entity.id] = entity.model
            }
        }
        return list
    }

    func filter(id: String) async -> FilterModel? {
        var result: FilterModel?
        filterMaps.withLock { filterMap in
            result = filterMap[id]
        }
        return result
    }
}




final class FilterCoordinatorImp: FilterCoordinator {
    func fetchAll() async -> [any TitledContent] {
        return await repository.fetchAll()
    }
    
    private let repository: FilterRepository
    let selectionSender: FilterModelSelectionSender

    init(repository: FilterRepository, sender: FilterModelSelectionSender) {
        self.repository = repository
        self.selectionSender = sender
    }

    @discardableResult
    func selectFilter(id: String) async -> Bool {
        guard let filter = await repository.filter(id: id) else { return false }
        selectionSender.send(model: filter)
        
        return true
    }
    
    deinit {
        print("filter dinit")
    }
    
    
}


