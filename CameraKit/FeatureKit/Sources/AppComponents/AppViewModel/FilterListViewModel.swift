import Foundation
import Observation
import CoreKit
import DomainApi


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

    //public private(set) var items: [TitledContent] = []
    
    @MainActor
    public var viewData: FilterListViewData = FilterListViewData()
    
    let continuation: AsyncStream<FilterAction>.Continuation
    
    @ObservationIgnored
    var task: Task<Void,Never>? = nil

    public init(
        coordinator: FilterCoordinator
    ) {
        self.coordinator = coordinator
        let value = AsyncStream<FilterAction>.make()
        self.continuation = value.1
        continuation.yield(.refresh)
        task = listenStream(stream:value.0)
    }
    
    func listenStream(stream: AsyncStream<FilterAction>) -> Task<Void,Never>? {
        let task = Task { [weak self] in
            guard let self else {
                return
            }
            for await action in stream {
                await self.perform(action)
            }
        }
        return task
    }
    
    func perform(_ task: FilterAction) async {
        switch task {
        case .refresh:
            await self.refresh()
        case .select(let i):
            await self.selectItem(at: i)
        }
        
    }
    

    
    deinit {
        task?.cancel()
        
    }
    
    @MainActor
    public func refresh() async {
        let items = await coordinator.fetchAll()
        viewData.filters = items.map {FilterViewData(title: $0.title, id:$0.id)}
    }


    public func selectItem(at index: Int) async {
        guard await viewData.filters.indices.contains(index) else { return }
            let item = await viewData.filters[index].id
            await try? coordinator.selectFilter(id: item)
    }
    
    public func trigger(_ action: FilterAction) {
        continuation.yield(action)
    }
}
