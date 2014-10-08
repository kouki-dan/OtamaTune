//
//  AudioController.m
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import "AudioController.h"

#define kOutputBus 0
#define kInputBus 1

@implementation AudioController
@synthesize rioUnit, audioFormat, delegate;


+ (AudioController *) sharedAudioManager
{
    static AudioController *sharedAudioManager;
    
    @synchronized(self)
    {
        if (!sharedAudioManager) {
            sharedAudioManager = [[AudioController alloc] init];
            [sharedAudioManager startAudio];
        }
        return sharedAudioManager;
    }
}


void checkStatus(OSStatus status);
void checkStatus(OSStatus status) {
    if(status!=0)
        printf("Error: %ld\n", status);
}

#pragma mark init

- (id)init
{
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &rioUnit);
    checkStatus(status);
    
    
    // Enable IO for recording
    UInt32 flag = 1;
    
    status = AudioUnitSetProperty(rioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    
    // Describe format
    audioFormat.mSampleRate= 44100.0;
    audioFormat.mFormatID= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket= 1;
    audioFormat.mChannelsPerFrame= 1;
    audioFormat.mBitsPerChannel= 16;
    audioFormat.mBytesPerPacket= 2;
    audioFormat.mBytesPerFrame= 2;
    
    // Apply format
    status = AudioUnitSetProperty(rioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    status = AudioUnitSetProperty(rioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge_retained void*)self;
    
    status = AudioUnitSetProperty(rioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    
    // Disable buffer allocation for the recorder
    flag = 0;
    status = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Global, kInputBus, &flag, sizeof(flag));
    
    
    // Initialise
    status = AudioSessionInitialize(NULL, NULL, NULL, (__bridge void*) self);
    checkStatus(status);
    
    
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    checkStatus(status);
    
    status = 0;
    status = AudioSessionSetActive(YES);
    checkStatus(status);
    
    status = AudioUnitInitialize(rioUnit);
    checkStatus(status);
    
    return self;
}

#pragma mark Recording Callback
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    AudioController *THIS = (__bridge AudioController*) inRefCon;
    
    THIS->bufferList.mNumberBuffers = 1;
    THIS->bufferList.mBuffers[0].mDataByteSize = sizeof(SInt16)*inNumberFrames;
    THIS->bufferList.mBuffers[0].mNumberChannels = 1;
    THIS->bufferList.mBuffers[0].mData = (SInt16*) malloc(sizeof(SInt16)*inNumberFrames);
    
    OSStatus status;
    
    status = AudioUnitRender(THIS->rioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &(THIS->bufferList));
    checkStatus(status);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [THIS.delegate  receivedAudioSamples:(SInt16*)THIS->bufferList.mBuffers[0].mData length:inNumberFrames];
    });
    return noErr;
}



-(void) startAudio
{
    OSStatus status = AudioOutputUnitStart(rioUnit);
    checkStatus(status);
    printf("Audio Initialized - sampleRate: %f\n", audioFormat.mSampleRate);
}

@end