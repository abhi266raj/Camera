//
//  VideoRecorder.swift
//  CameraKit
//
//  Created by Abhiraj on 09/10/23.
//

import Foundation
import AVFoundation
import UIKit
import CoreMedia
import PlatformApi

class VideoRecorderImp: VideoRecorder {
    func contentOutput(_ output: any ContentReciever, didRecieved sampleBuffer: CMSampleBuffer) {
        appendSampleBuffer(sampleBuffer)
    }
    
    var isRecording: Bool = false
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var audioWriterInput: AVAssetWriterInput?
    private var outputURL: URL

    init(outputURL: URL, rotationAngle: CGFloat = CGFloat.pi/2) {
        self.outputURL = outputURL
        do {
            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            

            // Create video settings
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 1920, // Your desired video width
                AVVideoHeightKey: 1080, // Your desired video height
            ]

            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoWriterInput?.expectsMediaDataInRealTime = true
            videoWriterInput?.transform = CGAffineTransform(rotationAngle: rotationAngle)
            if videoWriter!.canAdd(videoWriterInput!) {
                videoWriter!.add(videoWriterInput!)
            } else {
                // Handle error
            }

            // Create audio settings
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 128000
            ]

            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioWriterInput?.expectsMediaDataInRealTime = true
            if videoWriter!.canAdd(audioWriterInput!) {
                videoWriter!.add(audioWriterInput!)
            } else {
                // Handle error
            }
        } catch {
            // Handle error
        }
    }

    func startRecording() {
        if !isRecording {
            isRecording = true
            videoWriter?.startWriting()
        }
    }

    func stopRecording(completion: @escaping (URL) -> Void) {
        if isRecording {
            isRecording = false
            videoWriterInput?.markAsFinished()
            audioWriterInput?.markAsFinished()
            let result = outputURL
            videoWriter?.finishWriting(completionHandler: {
                // Handle the completion of writing here
                completion(result)
            })
        }
    }

    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        let sampleType = getSampleType(from: sampleBuffer)
        if isRecording {
            if sampleType == kCMMediaType_Video {
                if let videoWriterInput = videoWriterInput, videoWriterInput.isReadyForMoreMediaData {
                    startSessionIfNeeded(atSourceTime: CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer))
                    if videoWriterInput.append(sampleBuffer) {
                        
                    } else {
                        
                    }
                }
            }

            if sampleType == kCMMediaType_Audio  && isSessionStarted{
                if let audioWriterInput = audioWriterInput, audioWriterInput.isReadyForMoreMediaData {
                    if audioWriterInput.append(sampleBuffer) {
                        // Successfully appended audio sample buffer
                    } else {
                        // Handle error
                    }
                }
            }
        }
    }
    
    func getSampleType(from sampleBuffer: CMSampleBuffer) -> CMMediaType {
        if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let mediaType = CMFormatDescriptionGetMediaType(formatDescription)
            return mediaType
        }
        return kCMMediaType_Metadata
    }
    
    var isSessionStarted = false
    func startSessionIfNeeded(atSourceTime time: CMTime) {
        if isSessionStarted {
            return
        }
        guard let videoWriter else { return}
        videoWriter.startSession(atSourceTime: time)
       isSessionStarted = true
    }
}

