import Foundation
import Observation
import CoreKit
import DomainApi
import Combine

public enum FilterAction: Sendable {
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



@Observable final public class FilterListViewData:  Sendable {
    
    @MainActor
    public var count: Int  {
        return filters.count
    }
    @MainActor
    public var filters: [FilterViewData] = []
    nonisolated public init() {
        
    }
}

public protocol FilterListViewModel: ActionableViewModel {
    @MainActor
    var viewData: FilterListViewData {get}
    func trigger(_ action: FilterAction)
    func activate()  async
}

@Observable
final public class FilterListViewModelImp: FilterListViewModel {
    
    private let coordinator: FilterCoordinator

    public var viewData: FilterListViewData = FilterListViewData()
    
    private let continuation: AsyncStream<FilterAction>.Continuation
    private let stream: AsyncStream<FilterAction>
    
    public init(
        coordinator: FilterCoordinator
    ) {
        self.coordinator = coordinator
        let value = AsyncStream<FilterAction>.make()
        self.continuation = value.1
        stream = value.0
    }
    
    public func activate() async {
        trigger(.refresh)
        for await action in stream {
            await self.perform(action)
        }
    }
    
    
    func perform(_ task: FilterAction) async {
        switch task {
        case .refresh:
            await self.refresh()
        case .select(let i):
            await self.selectItem(at: i)
        }
    }
    
    func refresh() async {
        let items = await coordinator.fetchAll()
        let list = items.map {FilterViewData(title: $0.title, id:$0.id)}
        @MainActor func updateFilters(viewData: FilterListViewData = self.viewData) {
            viewData.filters = list
        }
        await updateFilters()
    }
    
    @MainActor func updateFilters(items: [TitledContent]) {
        let list = items.map {FilterViewData(title: $0.title, id:$0.id)}
        viewData.filters = list
    }

     func fetchId(at index: Int) async -> String? {
        @MainActor func fetchId(viewData: FilterListViewData = self.viewData) ->String? {
            guard viewData.filters.indices.contains(index) else { return nil }
            let item = viewData.filters[index].id
            return item
        }
       return  await fetchId()
    }
    
    func selectItem(at index: Int) async  {
        let id = await fetchId(at: index)
        guard let id else {return}
        coordinator.selectFilter(id: id)
    }
    
    public func trigger(_ action: FilterAction) {
        continuation.yield(action)
    }
}

