import Foundation
import Observation
import CoreKit
import DomainKit_api


@Observable
final public class FilterListViewModel: @unchecked Sendable {
    private let cameraService: CameraService
    private let repository: FilterRepository

    private(set) var items: [FilterEntity] = []

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
