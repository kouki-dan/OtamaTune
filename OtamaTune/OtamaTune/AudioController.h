//
//  AudioController.h
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioControllerDelegate
@required
- (void) receivedAudioSamples:(SInt16*) samples length:(int) len;
@end

@interface AudioController : NSObject
{
@public
    AudioBufferList bufferList;
}
@property (nonatomic, assign) AudioStreamBasicDescription audioFormat;
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) id<AudioControllerDelegate> delegate;

+ (AudioController*) sharedAudioManager;
- (void) startAudio;


@end