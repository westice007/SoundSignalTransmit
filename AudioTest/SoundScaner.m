//
//  SoundScaner.m
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import "SoundScaner.h"
#import "Speaker.h"

//char starterBuffer[10];
//char enderBuffer[10];

int starterBufferIndex;
int enderBufferIndex;



static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;


@interface SoundScaner ()

@property (nonatomic,strong) EZMicrophone *microphone;

/**
 Used to calculate a rolling FFT of the incoming audio data.
 */
@property (nonatomic, strong) EZAudioFFTRolling *fft;


@property (nonatomic, assign)int prevChrIndex;

@property(nonatomic,assign)int scanState; //0:读开始头   1:读正文     2:读结束头

@property (nonatomic, strong)NSMutableString* contentBuffer;


@end


@implementation SoundScaner

-(id)init{
    self = [super init];

    self.prevChrIndex = -2;
    
    self.scanState = 0;
    
    self.contentBuffer = [NSMutableString stringWithCapacity:10];
    
    
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
    
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    float maxFrequency = [fft maxFrequency];
    //NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency includeOctave:YES];
    //NSLog(@"notename:%@",noteName);
    //__weak typeof (self) weakSelf = self;
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        if (maxFrequency >= (FREQUENCE_THRESH - FREQUENCE_STEP*6)) {
            //NSLog(@"receive .frequency:%f",maxFrequency);
            //将频率转化为对应的char
            int chrIndex = -2;
            if (maxFrequency > GAP_FREQUENCE - FREQUENCE_STEP*2) {
                //分隔期
                
                //抗干扰
                //int rightF = GAP_FREQUENCE;
                //if (abs(rightF - maxFrequency) < 20) {
                //    NSLog(@"分隔信号");
                //}
                chrIndex = -1;
                
            }else{
                chrIndex = (maxFrequency - FREQUENCE_THRESH)/FREQUENCE_STEP;
                //NSLog(@"f:%f charValue:%d",maxFrequency,charValue);
                //unsigned char chr = charValue;

            }
            
            if (chrIndex >= 0 && chrIndex < 64 && self.prevChrIndex != chrIndex) {
                //NSLog(@"base64:%c",Base64Strs[chrIndex]);
                char chr = Base64Strs[chrIndex];
                printf("%c",chr);
                
                if (self.scanState == 0) {
                    //读开始头
                    if (chr == starter[starterBufferIndex]) {
                        starterBufferIndex++;
                    }else{
                        //打断读取
                        starterBufferIndex = 0;
                    }
                    
                    if (starterBufferIndex == strlen(starter)) {
                        NSLog(@"读到头了");
                        starterBufferIndex = 0;
                        self.scanState = 1;
                        [self.contentBuffer setString:@""];
                    }
                    
                    
                }else if (self.scanState == 1){
                    
                    //一边读正文还要一边检测结束头
                    [self.contentBuffer appendFormat:@"%c",chr];
                    
                    if (chr == ender[enderBufferIndex]) {
                        enderBufferIndex++;
                    }else{
                        //打断读取
                        enderBufferIndex = 0;
                    }
                    
                    if (enderBufferIndex == strlen(ender)) {
                        NSLog(@"读到尾巴了");
                        enderBufferIndex = 0;
                        self.scanState = 2;
                        //[self.contentBuffer setString:@""];
                    }
                    
                }else if (self.scanState == 2){
                    //处理掉尾巴
                    int enderLen = strlen(ender);
                    int allBufLen = [self.contentBuffer length];
                    [self.contentBuffer deleteCharactersInRange:NSMakeRange(allBufLen - enderLen, enderLen)];
                    NSLog(@"正文：%@",self.contentBuffer);
                    
                    
                    //还原状态
                    self.scanState = 0;
                    [self.contentBuffer setString:@""];
                }
                
            }
            
            
            
            
            self.prevChrIndex = chrIndex;
            
        }
        
        
    //});
}





@end
