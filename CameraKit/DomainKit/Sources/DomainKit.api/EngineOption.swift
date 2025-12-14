//
//  EngineOption.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//


public enum EngineOption: Sendable {
    
   
    
    public enum Display: Sendable, CaseIterable {
        case metal
        case multicam
        case basic
    }

    public enum Storage: Sendable, CaseIterable {
        case unavailable
        case photo
        case video
    }
    
    public enum IO: Sendable, CaseIterable {
        // Actions
        case toggle
        case start
        case pause
        
        // Capabilities
        case flash
        case torch
        case zoom
        
        // Filters
        case metalFilter
        case ciFilter
        
        static public func allFilters() -> Set<IO> {
            return [.metalFilter, .ciFilter]
        }
    }
    
    
    public struct Config: Sendable, Equatable, Hashable {
        public let display: Display
        public let storage: Storage
        public let inputOutput: Set<IO>
        
        public init(display: Display, storage: Storage, inputOutput: Set<IO>) {
            self.display = display
            self.storage = storage
            self.inputOutput = inputOutput
        }
    }

   
}

public extension EngineOption {
    public struct Capabilty: Sendable {
        public let display: Set<Display>
        public let storage: Set<Storage>
        public let inputOutput: Set<IO>
        
        public init(display: Set<Display>, storage: Set<Storage>, inputOutput: Set<IO>) {
            self.display = display
            self.storage = storage
            self.inputOutput = inputOutput
        }
    }
}

public extension EngineOption.Capabilty {
    func allPossibleConfig() -> [EngineOption.Config] {
        let filterIO = EngineOption.IO.allFilters()
        return display.flatMap { displayOption in
            storage.flatMap { storageOption in
                let allowedIO = displayOption == .metal
                    ? inputOutput
                    : inputOutput.subtracting(filterIO)
                
                return [EngineOption.Config(
                    display: displayOption,
                    storage: storageOption,
                    inputOutput: allowedIO
                )]
            }
        }
    }
}
