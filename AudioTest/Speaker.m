//
//  Speaker.m
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import "Speaker.h"

@interface Speaker ()

@property(nonatomic,strong)EZOutput* outPut;
@property (nonatomic) double theta;
@property (nonatomic) double amplitude;
@property (nonatomic) double frequency;

@property (nonatomic,assign)int signalIndex;

@property(nonatomic,strong)NSTimer* timer;

@property (nonatomic,assign)double microSecAcc;

@end


static unsigned char testChrs[8] = {'B','o','o','k','i','s','m','y'};

@implementation Speaker

-(id)init{
    self = [super init];
    
    self.theta = 0;
    self.amplitude = 0.6;//音量
    self.frequency = FREQUENCE_THRESH + 8000;
    
    self.microSecAcc = 0;
    
    AudioStreamBasicDescription inputFormat = [EZAudioUtilities monoFloatFormatWithSampleRate:SAMPLE_RATE];
    self.outPut = [EZOutput outputWithDataSource:self inputFormat:inputFormat];
    [self.outPut setDelegate:self];
    
    
    
    
    return self;
}

-(void)start{
    
    
    self.microSecAcc = CFAbsoluteTimeGetCurrent();
    
    [self.outPut startPlayback];
    
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    
    
    
}


-(void)timerHandler{
    NSLog(@"test:%f",CFAbsoluteTimeGetCurrent());
}

-(void)stop{
    [self.outPut stopPlayback];
    [self.timer invalidate];
}



//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    
    
    double timeElapse = CFAbsoluteTimeGetCurrent() - self.microSecAcc;
    
    //NSLog(@"timeElapse:%f",timeElapse);
    if (timeElapse <= ONE_SIGNAL_TIME + ONE_GAP_SIGNAL_TIME) {
        
        if (timeElapse < ONE_SIGNAL_TIME) {
            if (self.signalIndex >= sizeof(testChrs)) {
                self.signalIndex = 0;
            }
            unsigned char chr = testChrs[self.signalIndex];
            self.frequency = FREQUENCE_THRESH + FREQUENCE_STEP/2 + chr*FREQUENCE_STEP;
            
            NSLog(@"send chr:%c .frequency:%f",chr,self.frequency);
            
        }else{
            //信号走完，开始分隔信号
            self.frequency = FREQUENCE_THRESH - FREQUENCE_STEP/2;
            NSLog(@"send gap frequence:%f",self.frequency);
        }
        
    }else{
        //分隔信号信号走完,开始下一个
        self.signalIndex++;
        self.microSecAcc = CFAbsoluteTimeGetCurrent();
        
        
    }
    
    
    
    Float32 *buffer = (Float32 *)audioBufferList->mBuffers[0].mData;
    size_t bufferByteSize = (size_t)audioBufferList->mBuffers[0].mDataByteSize;
    double theta = self.theta;
    double frequency = self.frequency;
    double thetaIncrement = 2.0 * M_PI * frequency / SAMPLE_RATE;
    for (UInt32 frame = 0; frame < frames; frame++)
    {
        buffer[frame] = self.amplitude * sin(theta);
        theta += thetaIncrement;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    self.theta = theta;
    
    
    //NSLog(@"clock:%ld",clock());
    
    
    
    
    
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDelegate
//------------------------------------------------------------------------------

- (void)       output:(EZOutput *)output
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}





@end
