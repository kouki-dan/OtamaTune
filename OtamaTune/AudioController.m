//
//  AudioController.m
//  OtamaTune
//
//  Created by Kouki Saito on 2014/08/31.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface AudioController ()

@property (nonatomic, assign) AudioStreamBasicDescription inputAudioFormat;
@property (nonatomic, assign) AudioQueueRef inputQueue;

@end

@implementation AudioController

- (id) init{
    
    OSStatus status = noErr;
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if(audioSession.inputAvailable){
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    }
    [audioSession setActive:YES error:&error];
    

    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.0;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBytesPerFrame = 2;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mReserved = 0;

    AudioQueueRef queue;

    status = AudioQueueNewInput(&audioFormat, AudioInputCallback, (__bridge_retained void *)self,
                       CFRunLoopGetCurrent(),kCFRunLoopCommonModes,0,&queue);
    NSAssert(status == noErr, @"Failed to create new input queue.");

    
    UInt32 dataFormatSize = sizeof(audioFormat);
    status = AudioQueueGetProperty(queue,
                                   kAudioQueueProperty_StreamDescription,
                                   &audioFormat,
                                   &dataFormatSize);
    NSAssert(status == noErr, @"Failed to update basic stream description.");

    self.inputAudioFormat = audioFormat;
    self.inputQueue = queue;

    UInt32 bufferByteSize = audioFormat.mBytesPerPacket * 1024;

    
    AudioQueueBufferRef buffers[3];
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < 3; bufferIndex++) {
        AudioQueueAllocateBuffer(queue,
                                 bufferByteSize, &buffers[bufferIndex]);
        AudioQueueEnqueueBuffer(queue,
                                buffers[bufferIndex], 0, NULL);
    }

    AudioQueueStart(queue, NULL);

    
    
    return self;
}

static void AudioInputCallback(
                               void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs)
{
    //NSLog(@"%p", inBuffer->mAudioData);
    /*
    AudioBuffer buffer = {
        .mNumberChannels = 1,
        .mDataByteSize = inBuffer->mAudioDataByteSize,
        .mData = inBuffer->mAudioData
    };
    */
    
    //NSLog(@"%p", inUserData);
    
    
    AudioController *ac = (__bridge AudioController *)inUserData;
    void *data = inBuffer->mAudioData;
    int size = inBuffer->mAudioDataByteSize;
    
    //NSLog(@"%p",ac);
    [ac.delegate receivedAudioSamples:data length:size];
    
    
    
    // Enqueue the used Buffer.
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);

    //AVAudioRecorder* recorder = (AVAudioRecorder*) CFBridgingRelease(inUserData);
    /*
    OSStatus status = AudioFileWritePackets(
                                            recorder.audioFile,
                                            NO,
                                            inBuffer->mAudioDataByteSize,
                                            inPacketDescs,
                                            recorder.currentPacket,
                                            &inNumberPacketDescriptions,
                                            inBuffer->mAudioData);
    
    if (status == noErr) {
        recorder.currentPacket += inNumberPacketDescriptions;
        AudioQueueEnqueueBuffer(recorder.queue,inBuffer,0,nil);
    }
     */
}


@end
