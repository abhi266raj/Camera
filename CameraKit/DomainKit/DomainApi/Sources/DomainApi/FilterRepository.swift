//
//  FilterRepository.swift
//  DomainKit
//
//  Created by Abhiraj on 08/12/25.
//


import CoreKit

public protocol FilterCoordinator {
    
    func fetchAll() async -> [TitledContent]
    @discardableResult
    func selectFilter(id: String) -> Bool 
}
