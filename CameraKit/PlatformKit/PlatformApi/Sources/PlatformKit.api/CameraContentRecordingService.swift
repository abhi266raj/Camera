//
//  CameraDiskOutputService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import CoreKit
import AVFoundation

public protocol PhotoClickWorker: Sendable {
    func clickPhoto(_ output: AVCapturePhotoOutput, imageCaptureConfig:ImageCaptureConfig) async -> AsyncThrowingStream<AVCapturePhoto, Error>
    func savePhotoToLibrary(_ photo: AVCapturePhoto) async throws
}

public protocol BasicVideoRecordWorker: Sendable {
    func startRecording(_ output: AVCaptureMovieFileOutput, url: URL?) async -> AsyncThrowingStream<URL, Error>
    func stopRecording(output: AVCaptureMovieFileOutput) throws
    func saveVideoToLibrary(_ outputFileURL: URL) async throws
}


public protocol SampleBufferVideoRecordingWorker:  ContentConnection{
    typealias ConnectionType = CMSampleBuffer
    func startRecording(url: URL?) async -> AsyncThrowingStream<URL, Error>
    func stopRecording() async  throws
    func saveVideoToLibrary(_ outputFileURL: URL) async throws
}

public protocol VideoRecorder: ContentReciever<CMSampleBuffer> {
    typealias Content = CMSampleBuffer
    func startRecording()
    func stopRecording(completion: @escaping (URL) -> Void)
}
