import Foundation
import Observation

@Observable
final class FilterListViewModel {
    private let cameraService: CameraService
    private let repository: FilterRepository

    private(set) var items: [FilterEntity] = []

    init(
        cameraService: CameraService = CameraServiceBuilder().getService(cameraType: .camera),
        repository: FilterRepository = FilterRepositoryImpl()
    ) {
        self.cameraService = cameraService
        self.repository = repository
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        items = await repository.fetchAll()
    }

    var count: Int { items.count }

    func title(for index: Int) -> String {
        guard items.indices.contains(index) else { return "" }
        return items[index].title
    }

    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        cameraService.updateSelection(filter: items[index].model)
    }
}
