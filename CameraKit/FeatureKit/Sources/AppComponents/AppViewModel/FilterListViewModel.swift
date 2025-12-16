import Foundation
import Observation
import CoreKit
import DomainApi


public enum FilterAction {
    case refresh
    case select(index:Int)
}

public struct FilterViewData {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

@Observable final public class FilterListViewData {
    public var count: Int  {
        return filters.count
    }
    public var filters: [FilterViewData] = []
    public init() {
        
    }
}

public protocol FilterListViewModel: ActionableViewModel {
    @MainActor
    var viewData: FilterListViewData {get}
    func trigger(_ action: FilterAction)
    
}

@Observable
final public class FilterListViewModelImp: @preconcurrency FilterListViewModel, @unchecked Sendable {
    
    private let cameraService: CameraEngine
    private let repository: FilterRepository

    public private(set) var items: [FilterEntity] = []
    
    @MainActor
    public var viewData: FilterListViewData = FilterListViewData()

    public init(
        cameraService: CameraEngine,
        repository: FilterRepository
    ) {
        self.cameraService = cameraService
        self.repository = repository
        Task {
            await refresh()
        }
    }
    
    @MainActor
    public func refresh() async {
        items = await repository.fetchAll()
        viewData.filters = items.map {FilterViewData(title: $0.title)}
    }


    public func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        Task {
            await try? cameraService.perform(.updateFilter(items[index].model))
        }
        //cameraService.updateSelection(filter: items[index].model)
    }
    
    public func trigger(_ action: FilterAction) {
        switch action {
        case .refresh:
                Task { @MainActor in
                    await self.refresh()
                }
            break
        case .select(let i):
            selectItem(at: i)
            break
        }
    }
}

