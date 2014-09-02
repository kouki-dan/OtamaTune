//
//  AudioController.h
//  OtamaTune
//
//  Created by Kouki Saito on 2014/08/31.
//  Copyright (c) 2014年 Kouki. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AudioControllerDelegate
@required
- (void) receivedAudioSamples:(SInt16*) samples length:(int) len;
@end


@interface AudioController : NSObject

@property (nonatomic, assign) id<AudioControllerDelegate> delegate;



@end
