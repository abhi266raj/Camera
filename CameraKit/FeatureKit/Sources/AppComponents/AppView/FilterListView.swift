//
//  FilterListView.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import AppViewModel
import SwiftUI

struct FilterListView: MultiActionableView {
    
    let viewData: FilterListViewData
    let onAction: (FilterAction) -> Void
    
    init(viewModel: FilterListViewModel) {
        self.init(viewData: viewModel.viewData) { action in
            viewModel.trigger(action)
        }
    }
    
    init(viewData: FilterListViewData, onAction: @escaping (FilterAction) -> Void = {_ in }) {
        self.viewData = viewData
        self.onAction = onAction
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: 10) {
                ForEach(0..<viewData.count, id: \.self) { index in
                    Button(action: {
                        onAction(.select(index: index))
                    }) {
                        Text(viewData.filters[index].title)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 80)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.gray)
                            )
                    }
                }
            }.frame(height: 60)
        }
    }
}

#Preview {
    let viewData = FilterListViewData()
    viewData.filters = [FilterViewData(title: "First"), FilterViewData(title: "Second"), FilterViewData(title: "First")]
    return FilterListView(viewData: viewData)
}
