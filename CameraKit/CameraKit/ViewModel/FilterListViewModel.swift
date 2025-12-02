//
//  FilterListViewModel.swift
//  CameraKit
//
//  Created by Abhiraj on 02/12/25.
//

import Foundation
import Observation
import CoreImage

@Observable
final class FilterListViewModel {
    // Nested model lives inside the ViewModel per request
    struct FilterItem {
        let title: String
        let model: any FilterModel
    }

    private var items: [FilterItem] = [
        FilterItem(title: "Monochrome", model: CIFilterModel(contents: CIFilter(name: "CIColorMonochrome")!)),
        FilterItem(title: "Metal", model: MetalFilterModel()),
        FilterItem(title: "Green Effect", model: MetalFilterModel(contents: "greenEffect")),
        FilterItem(title: "D2", model: MetalFilterModel(contents: "d2")),
        FilterItem(title: "None", model: EmptyFilterModel())
    ]

    // The selection callback is owned by the ViewModel
    private let onItemSelection: (any FilterModel) -> Void
    private let cameraService: CameraService

    init(cameraService: CameraService = CameraServiceBuilder().getService(cameraType: .camera)) {
        self.cameraService = cameraService
        self.onItemSelection = { filter in
            cameraService.updateSelection(filter: filter )
        }
    }

    var count: Int { items.count }

    func title(for index: Int) -> String {
        guard items.indices.contains(index) else { return "" }
        return items[index].title
    }

    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        let filter = items[index].model
        cameraService.updateSelection(filter: filter)
    }
}
