//
//  ContentInput.swift
//  CameraKit
//
//  Created by Abhiraj on 24/12/25.
//

import CoreMedia

public protocol ContentInput: class {
    var contentProduced: ((CMSampleBuffer) -> Void)? { get set }
}

public protocol ContentOutput: class {
    func contentOutput(
        _ output: ContentOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: ContentConnection
    )
}

public protocol ContentConnection: class {
    var input: ContentInput { get }
    var output: ContentOutput? { get }
}

public class MultiContentInput: ContentInput {
    
    
    public init() {
        
    }
    private var inputs: [ContentInput] = []
    public var contentProduced: ((CMSampleBuffer) -> Void)?  {
        didSet {
            for input in inputs {
                input.contentProduced = contentProduced
            }
        }
    }
    
    public func insert(_ input: ContentInput) {
        input.contentProduced = contentProduced
        inputs.append(input)
    }
    
}
