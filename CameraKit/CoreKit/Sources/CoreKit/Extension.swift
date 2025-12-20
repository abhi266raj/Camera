//
//  Extension.swift
//  CameraKit
//
//  Created by Abhiraj on 20/12/25.
//



public extension AsyncStream {
     public static func make() -> (Self, Self.Continuation) {
        var cont: Self.Continuation!
        let stream = AsyncStream(Element.self) { continuation in
            cont = continuation
        }
        return (stream, cont)
    }
}
