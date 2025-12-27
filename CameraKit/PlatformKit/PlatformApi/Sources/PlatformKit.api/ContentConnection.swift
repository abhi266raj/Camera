//
//  ContentInput.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//


public protocol ContentProducer: class {
    associatedtype Content
    var contentProduced: ((Content) -> Void)? { get set }
}

public protocol ContentReciever: class {
    associatedtype Content
    func contentOutput(
        _ output: ContentReciever,
        didOutput sampleBuffer: Content,
        from connection: ContentConnection
    )
}


public protocol ContentConnection: class {
    associatedtype ConnectionType
    func setUpConnection<Producer:ContentProducer, Consumer:ContentReciever>(_ producer: Producer, reciever: Consumer?) where Producer.Content == ConnectionType,  Consumer.Content == ConnectionType
}

