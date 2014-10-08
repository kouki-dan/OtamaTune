//
//  PitchDetector.m
//  OtamaTune
//
//  Created by Kouki Saito on 2014/10/08.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import "PitchDetector.h"
#import <Accelerate/Accelerate.h>


@implementation PitchDetector
@synthesize lowBoundFrequency, hiBoundFrequency, sampleRate, delegate, running;

#pragma mark Initialize Methods


-(id) initWithSampleRate: (float) rate andDelegate: (id<PitchDetectorDelegate>) initDelegate {
    return [self initWithSampleRate:rate lowBoundFreq:40 hiBoundFreq:4500 andDelegate:initDelegate];
}

-(id) initWithSampleRate: (float) rate lowBoundFreq: (int) low hiBoundFreq: (int) hi andDelegate: (id<PitchDetectorDelegate>) initDelegate {
    self.lowBoundFrequency = low;
    self.hiBoundFrequency = hi;
    self.sampleRate = rate;
    self.delegate = initDelegate;
    
    bufferLength = self.sampleRate/self.lowBoundFrequency*2;
    
    
    hann = (float*) malloc(sizeof(float)*bufferLength);
    vDSP_hann_window(hann, bufferLength, vDSP_HANN_NORM);
    
    sampleBuffer = (SInt16*) malloc(512);
    samplesInSampleBuffer = 0;
    
    result = (float*) malloc(sizeof(float)*bufferLength);
    
    return self;
}

#pragma  mark Insert Samples

- (void) addSamples:(SInt16 *)samples inNumberFrames:(int)frames {
    int newLength = frames;
    if(samplesInSampleBuffer>0) {
        newLength += samplesInSampleBuffer;
    }
    
    SInt16 *newBuffer = (SInt16*) malloc(sizeof(SInt16)*newLength);
    memcpy(newBuffer, sampleBuffer, samplesInSampleBuffer*sizeof(SInt16));
    memcpy(&newBuffer[samplesInSampleBuffer], samples, frames*sizeof(SInt16));
    
    free(sampleBuffer);
    sampleBuffer = newBuffer;
    samplesInSampleBuffer = newLength;
    
    if(samplesInSampleBuffer>(self.sampleRate/self.lowBoundFrequency)) {
        if(!self.running) {
            [self performSelectorInBackground:@selector(performWithNumFrames:) withObject:[NSNumber numberWithInt:newLength]];
            self.running = YES;
        }
        samplesInSampleBuffer = 0;
    } else {
        //printf("NOT ENOUGH SAMPLES: %d\n", newLength);
    }
}

-(BOOL) samplesIsSoundless:(SInt16 *) samples numFrames:(int)n{
    float max;
    //    float min;
    max = -1000000;
    //    min = 10000000;
    for(int i = 0; i<n; i++){
        max = MAX(max, samples[i]);
        //        min = MIN(min, samples[i]);
        if(max > 500){
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Perform Auto Correlation

-(void) performWithNumFrames: (NSNumber*) numFrames;
{
    int n = numFrames.intValue;
    float freq = 0;
    
    SInt16 *samples = sampleBuffer;
    
    int returnIndex = 0;
    float sum;
    bool goingUp = false;
    float normalize = 0;
    
    
    for(int i = 0; i<n; i++) {
        sum = 0;
        for(int j = 0; j<n; j++) {
            sum += (samples[j]*samples[j+i])*hann[j];
            
        }
        
        if(i == 0 ) normalize = sum;
        result[i] = sum/normalize;
        
    }
    
    
    for(int i = 0; i<n-8; i++) {
        if(result[i]<0) {
            i+=2; // no peaks below 0, skip forward at a faster rate
        } else {
            if(result[i]>result[i-1] && goingUp == false && i >1) {
                
                //local min at i-1
                
                goingUp = true;
                
            } else if(goingUp == true && result[i]<result[i-1]) {
                
                //local max at i-1
                
                if(returnIndex==0 && result[i-1]>result[0]*0.95) {
                    returnIndex = i-1;
                    break;
                }
                goingUp = false;
            }
        }
    }
    
    freq = self.sampleRate/interp(result[returnIndex-1], result[returnIndex], result[returnIndex+1], returnIndex);
    
    if([self samplesIsSoundless:samples numFrames:n]){
        freq = 0.0;
    }
    
    if((freq >= 27.5 && freq <= 4500.0 ) || freq == 0.0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate updatedPitch:freq];
            
        });
    }
    self.running = NO;
}


float interp(float y1, float y2, float y3, int k);
float interp(float y1, float y2, float y3, int k) {
    float d, kp;
    d = (y3 - y1) / (2 * (2 * y2 - y1 - y3));
    //printf("%f = %d + %f\n", k+d, k, d);
    kp  =  k + d;
    return kp;
}
@end
