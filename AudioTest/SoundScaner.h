//
//  SoundScaner.h
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#import "EZAudio.h"

@interface SoundScaner : NSObject<EZMicrophoneDelegate, EZAudioFFTDelegate>
-(void)start;
-(void)stop;
@end
