//
//  FilterListView.swift
//  CameraKit
//
//  Created by Abhiraj on 22/10/23.
//

import SwiftUI

struct FilterListView: View {
    private let viewModel: FilterListViewModel
    
    init(viewModel: FilterListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: 10) {
                ForEach(0..<viewModel.count, id: \.self) { index in
                    Button(action: {
                        viewModel.selectItem(at: index)
                    }) {
                        Text(viewModel.title(for: index))
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
                    .accessibilityLabel(viewModel.title(for: index))
                }
            }.frame(height: 60)
        }
    }
}
