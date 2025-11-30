//
//  FilterListView.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import SwiftUI

struct FilterListView: View {
    @State var filterListModel: FilterListModel = FilterListModel()
    var onItemSelection: (any FilterModel) -> Void
    
    init(onItemSelection: @escaping (any FilterModel) -> Void) {
        self.onItemSelection = onItemSelection
    }
    
    
    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 10) {
                    ForEach(filterListModel.model.indices, id: \.self) { index in
                        Button("\(index)", action: {
                            onItemSelection(filterListModel.model[index])
                        }).frame(width: 70, height: 50)
                    }
                }
            }
        }
    
    
}

struct FilterListModel {
    var model: [any FilterModel] = [CIFilterModel(contents: CIFilter(name: "CIColorMonochrome")!), MetalFilterModel(), MetalFilterModel(contents: "greenEffect"),MetalFilterModel(contents: "d2"), EmptyFilterModel()]
}
