//
//  ContentInput.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import CoreMedia

public protocol ContentProducer: class {
    var contentProduced: ((CMSampleBuffer) -> Void)? { get set }
}

public protocol ContentReciever: class {
    func contentOutput(
        _ output: ContentReciever,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: ContentConnection
    )
}

public protocol ContentConnection: class {
   
    func setUpConnection(_ producer: ContentProducer, reciever: ContentReciever?)
}

public class MultiContentInput: ContentProducer {
    
    
    public init() {
        
    }
    private var inputs: [ContentProducer] = []
    public var contentProduced: ((CMSampleBuffer) -> Void)?  {
        didSet {
            for input in inputs {
                input.contentProduced = contentProduced
            }
        }
    }
    
    public func insert(_ input: ContentProducer) {
        input.contentProduced = contentProduced
        inputs.append(input)
    }
    
}
