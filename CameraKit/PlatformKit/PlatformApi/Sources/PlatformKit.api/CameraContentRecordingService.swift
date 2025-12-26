//
//  CameraDiskOutputService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Combine
import CoreKit
import Foundation
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


public protocol SampleBufferDiskOutputService:  ContentConnection{
    func startRecording(url: URL?) async -> AsyncThrowingStream<URL, Error>
    func stopRecording() async  throws
    func saveVideoToLibrary(_ outputFileURL: URL) async throws
}

public protocol VideoOutput {
    func startRecord() async
    func stopRecord() async
    var videoSaver: VideoSaver {get}
    var videoRecorder: VideoRecorder? {get}
}

public protocol VideoSaver: Sendable {
    func saveVideo(from url: URL) async throws
}

public protocol VideoRecorder: ContentOutput {
    func startRecording()
    func stopRecording(completion: @escaping (URL) -> Void)
}
