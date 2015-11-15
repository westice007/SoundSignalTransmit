//
//  SoundScaner.m
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import "SoundScaner.h"
#import "Speaker.h"



static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;


@interface SoundScaner ()

@property (nonatomic,strong) EZMicrophone *microphone;

/**
 Used to calculate a rolling FFT of the incoming audio data.
 */
@property (nonatomic, strong) EZAudioFFTRolling *fft;

@end


@implementation SoundScaner

-(id)init{
    self = [super init];

    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    //
    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
    //
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];
    
    //
    // Start the mic
    //
    
    
    return self;
    
}


-(void)start{
    [self.microphone startFetchingAudio];
}

-(void)stop{
    [self.microphone stopFetchingAudio];
}



-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    //float* fftValue;
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    //printf("fftValue:%f  ",*fftValue);
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    float maxFrequency = [fft maxFrequency];
    NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency
                                                        includeOctave:YES];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (maxFrequency >= (FREQUENCE_THRESH - FREQUENCE_STEP*6)) {
            NSLog(@"receive .frequency:%f",maxFrequency);
            //将频率转化为对应的char
            if (maxFrequency < FREQUENCE_THRESH - FREQUENCE_STEP) {
                //分隔期
                
                //抗干扰
                int rightF = GAP_FREQUENCE;
                //if (abs(rightF - maxFrequency) < 20) {
                    NSLog(@"分隔信号");
                //}
                
            }else{
                int charValue = (maxFrequency - FREQUENCE_THRESH)/FREQUENCE_STEP;
                //NSLog(@"f:%f charValue:%d",maxFrequency,charValue);
                unsigned char chr = charValue;
                //抗干扰
                int rightF = FREQUENCE_THRESH + FREQUENCE_STEP/2 + chr*FREQUENCE_STEP;
                //if (abs(rightF - maxFrequency) < 30) {
                    NSLog(@"chr:%d",chr);
                //}
                
                
            
            }
            
        }
        
        
    });
}





@end
