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


public protocol ContentReciever<Content>: class {
    associatedtype Content
    func contentOutput(
        _ output: ContentReciever,
        didOutput sampleBuffer: Content,
        from connection: ContentConnection
    )
}

public protocol ContentConnection: class {
    associatedtype ConnectionType
    func createConnection(producer: ContentProducer<ConnectionType>, reciever: ContentReciever<ConnectionType>?)
}

