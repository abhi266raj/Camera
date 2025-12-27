//
//  ContentInput.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

public protocol ContentProducer<Content>: class {
    associatedtype Content
    var contentProduced: ((Content) -> Void)? { get set }
}


public protocol ContentReciever<Content>: class {
    associatedtype Content
    func contentOutput(
        _ output: ContentReciever,
        didRecieved: Content)
}

public protocol ContentConnection: class {
    associatedtype ConnectionType
    func createConnection(producer: ContentProducer<ConnectionType>, reciever: ContentReciever<ConnectionType>?)
}

