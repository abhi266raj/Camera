//
//  ContentInput.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import CoreMedia


public protocol ContentProducer<Content>: class {
    associatedtype Content
    var contentProduced: ((Content) -> Void)? { get set }
}

public extension ContentProducer {
    func asAnyProducer() -> AnyProducer<Content> {
        AnyProducer(self)
    }
}

public protocol ContentReciever<Content>: class {
    associatedtype Content
    func contentOutput(
        _ output: ContentReciever,
        didOutput sampleBuffer: Content,
        from connection: ContentConnection
    )
}

public extension ContentReciever {
    func asAnyReciever() -> AnyReciever<Content> {
        AnyReciever(self)
    }
}

public struct AnyProducer<Content> {
    public let content: any ContentProducer<Content>
    init<T:ContentProducer>(_ producer: T) where T.Content == Content {
        self.content = producer
    }
}

public struct AnyReciever<Content> {
    public let content: any ContentReciever<Content>
    init<T:ContentReciever>(_ reciever: T) where T.Content == Content {
        self.content = reciever
    }
}
    

public protocol ContentConnection: class {
    associatedtype ConnectionType
    func connect(producer: AnyProducer<ConnectionType>, reciever: AnyReciever<ConnectionType>?)
}

