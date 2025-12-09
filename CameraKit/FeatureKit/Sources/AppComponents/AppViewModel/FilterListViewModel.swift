import Foundation
import Observation
import CoreKit
import DomainKit_api

public protocol FilterListViewModel: Observable {
    var items: [FilterEntity] { get }
    var count: Int { get }
    func title(for index: Int) -> String
    func selectItem(at index: Int)
    func refresh() async
}

@Observable
final public class FilterListViewModelImp: FilterListViewModel, @unchecked Sendable {
    private let cameraService: CameraService
    private let repository: FilterRepository

    public private(set) var items: [FilterEntity] = []

    public init(
        cameraService: CameraService,
        repository: FilterRepository
    ) {
        self.cameraService = cameraService
        self.repository = repository
        Task {
            await refresh()
        }
    }
    
    public func refresh() async {
        items = await repository.fetchAll()
    }

    public var count: Int { items.count }

    public func title(for index: Int) -> String {
        guard items.indices.contains(index) else { return "" }
        return items[index].title
    }

    public func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        cameraService.updateSelection(filter: items[index].model)
    }
}
