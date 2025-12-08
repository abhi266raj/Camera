//
//  FilterRepository.swift
//  DomainKit
//
//  Created by Abhiraj on 08/12/25.
//


import CoreKit
import PlatformKit_runtime

// MARK: - Domain

public protocol FilterRepository {
    func fetchAll() async -> [FilterEntity]
}
