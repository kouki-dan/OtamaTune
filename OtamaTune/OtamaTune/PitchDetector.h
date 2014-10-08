//
//  PitchDetector.h
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PitchDetectorDelegate <NSObject>
- (void) updatedPitch: (float) frequency;
@end

@class AudioController;

@interface PitchDetector : NSObject
{
    float *hann, *result;
    SInt16 *sampleBuffer;
    int samplesInSampleBuffer;
    int bufferLength;
    int windowLength;
}

@property (nonatomic) BOOL running;
@property (nonatomic, assign) id<PitchDetectorDelegate> delegate;
@property int hiBoundFrequency, lowBoundFrequency;
@property float sampleRate;

//Optional Init Method (calls the second init method but sets the frequency bounds to default values)
-(id) initWithSampleRate: (float) rate andDelegate: (id<PitchDetectorDelegate>) initDelegate;
-(id) initWithSampleRate: (float) rate lowBoundFreq: (int) low hiBoundFreq: (int) hi andDelegate: (id<PitchDetectorDelegate>) initDelegate;
- (void) addSamples: (SInt16*) samples inNumberFrames: (int) frames;


@end

