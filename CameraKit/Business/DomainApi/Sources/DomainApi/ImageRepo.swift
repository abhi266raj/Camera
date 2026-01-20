//
//  ImageRepo.swift
//  CameraKit
//
//  Created by Abhiraj on 20/01/26.
//


import UIKit

public protocol ImageRepo: Sendable {
    func fetchImage(_ url: String) async throws -> UIImage
}
