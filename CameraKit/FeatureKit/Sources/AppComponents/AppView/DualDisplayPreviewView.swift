//
//  DualDisplayPreviewView.swift
//  FeatureKit
//
//  Created by Abhiraj on 14/12/25.
//

import Foundation
import UIKit
import PlatformKit_api
import CoreKit
import SwiftUI
import AppViewModel

struct DuaulCameraViewer: UIViewRepresentable {
    private let previewView =  DualDisplayPreviewView()
    let viewModel: CameraViewModel
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        
    }

    func makeUIView(context: Context) -> UIView {
        viewModel.attachDisplay(previewView)
        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
       
    }
}

public final class DualDisplayPreviewView: UIView {

    public enum Quadrant: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight, center
    }

    
    
    public var firstDisplayLayer: CALayer?
    public var secondDisplayLayer: CALayer?

   
    private let frontContainerView = UIView()
    private let backContainerView = UIView()
    private let quadrantButton = UIButton(type: .system)

    private var frontActiveConstraints: [NSLayoutConstraint] = []
    private var backConstraints: [NSLayoutConstraint] = []
    private var currentQuadrant: Quadrant = .center


    public init() {
        
        super.init(frame: .zero)

        clipsToBounds = true

     
        // setup views
        [backContainerView, frontContainerView, quadrantButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // ensure front is above back
        bringSubviewToFront(frontContainerView)
        bringSubviewToFront(quadrantButton)

       

        // optional appearance
        frontContainerView.clipsToBounds = true
        backContainerView.clipsToBounds = true

        quadrantButton.setTitle("Change", for: .normal)
        quadrantButton.translatesAutoresizingMaskIntoConstraints = false
        quadrantButton.addTarget(self, action: #selector(onChangeQuadrant), for: .touchUpInside)

        // back fills entire view (always)
        backConstraints = [
            backContainerView.topAnchor.constraint(equalTo: topAnchor),
            backContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(backConstraints)

        // quadrant button center
        NSLayoutConstraint.activate([
            quadrantButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            quadrantButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        applyLayout(for: currentQuadrant)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        secondDisplayLayer?.frame = backContainerView.bounds
        firstDisplayLayer?.frame = frontContainerView.bounds
        CATransaction.commit()
    }

    @objc private func onChangeQuadrant() {
        let all = Quadrant.allCases
        if let index = all.firstIndex(of: currentQuadrant) {
            let next = all[(index + 1) % all.count]
            applyLayout(for: next)
        }
    }

    private func applyLayout(for quadrant: Quadrant) {
        // deactivate previous front constraints
        NSLayoutConstraint.deactivate(frontActiveConstraints)
        frontActiveConstraints.removeAll()
        currentQuadrant = quadrant

        // common size for the front (half width & half height)
        let widthMultiplier: CGFloat = 0.5
        let heightMultiplier: CGFloat = 0.5

        switch quadrant {
        case .topLeft:
            frontActiveConstraints = [
                frontContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier),
                frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                frontContainerView.topAnchor.constraint(equalTo: topAnchor),
                frontContainerView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ]

        case .topRight:
            frontActiveConstraints = [
                frontContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier),
                frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                frontContainerView.topAnchor.constraint(equalTo: topAnchor),
                frontContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]

        case .bottomLeft:
            frontActiveConstraints = [
                frontContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier),
                frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                frontContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                frontContainerView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ]

        case .bottomRight:
            frontActiveConstraints = [
                frontContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier),
                frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                frontContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                frontContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]

        case .center:
            frontActiveConstraints = [
                frontContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier),
                frontContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier),
                frontContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                frontContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        }

        NSLayoutConstraint.activate(frontActiveConstraints)

        // Make sure front is visually above back and button is above both
        bringSubviewToFront(backContainerView)
        bringSubviewToFront(frontContainerView)
        bringSubviewToFront(quadrantButton)

        // animate layout change for smoothness
        UIView.animate(withDuration: 0.18) {
            self.layoutIfNeeded()
        }
    }
}



extension DualDisplayPreviewView: @MainActor DualDisplayLayerTarget {
    
    @MainActor
    public func addFirstDisplaylayer(_ layer: CALayer) async {
        frontContainerView.layer.addSublayer(layer)
    }
    
    @MainActor
    public func addSecondDisplaylayer(_ layer: CALayer) async {
        backContainerView.layer.addSublayer(layer)
    }
    
    
}
