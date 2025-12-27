//
//  ContentProducer.swift
//  CameraKit
//
//  Created by Abhiraj on 27/12/25.
//

import PlatformApi
import CoreMedia

protocol SampleBufferProducer: ContentProducer {
    typealias Content = CMSampleBuffer
}

protocol SampleBufferReciever: ContentReciever {
    typealias Content = CMSampleBuffer
}

protocol SampleBufferConnection: ContentConnection {
    typealias Producer =  SampleBufferProducer
    typealias Consumer =  SampleBufferReciever
    func setUpConnection(producer: Producer, reciever: Consumer?)
}


//public protocol ContentConnection: class {
//    associatedtype ConnectionType
//    func setUpConnection<Producer:ContentProducer, Consumer:ContentReciever>(_ producer: Producer, reciever: Consumer?) where Producer.Content == ConnectionType,  Consumer.Content == ConnectionType
//}
