import Foundation
import Observation
import CoreKit
import DomainApi


public enum FilterAction {
    case refresh
    case select(index:Int)
}

public struct FilterViewData: TitledContent {
    public let title: String
    public var id: String
    
    public init(title: String, id:String) {
        self.title = title
        self.id = id
    }
}

@MainActor
@Observable final public class FilterListViewData: Sendable {
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
final public class FilterListViewModelImp: FilterListViewModel, @unchecked Sendable {
    
    private let coordinator: FilterCoordinator

    public private(set) var items: [TitledContent] = []
    
    @MainActor
    public var viewData: FilterListViewData = FilterListViewData()

    public init(
        coordinator: FilterCoordinator
    ) {
        self.coordinator = coordinator
        Task {
            await refresh()
        }
    }
    
    @MainActor
    public func refresh() async {
        items = await coordinator.fetchAll()
        viewData.filters = items.map {FilterViewData(title: $0.title, id:UUID().uuidString)}
    }


    public func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        Task {
            let item = items[index].id
            await try? coordinator.selectFilter(id: item)
        }
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

