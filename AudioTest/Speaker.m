//
//  Speaker.m
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import "Speaker.h"



unsigned char Base64Strs[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',// 0 ~ 9
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',// 10 ~ 19
    'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',// 20 ~ 29
    'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',// 30 ~ 39
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',// 40 ~ 49
    'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',// 50 ~ 59
    '8', '9', '+', '/'// 60 ~ 63
};

char* starter = "lks";
char* ender = "lke";


@interface Speaker ()

@property (assign) GeneratorType type;

@property(nonatomic,strong)EZOutput* outPut;
@property (nonatomic) double theta;
@property (nonatomic) double amplitude;
@property (nonatomic) double frequency;

@property (nonatomic) double step;

@property (nonatomic,assign)int signalIndex;

@property(nonatomic,strong)NSTimer* timer;
@property(nonatomic,strong)NSMutableDictionary* Base64Index;

@property(nonatomic,strong)NSString* testBaseStr;

@property(nonatomic,strong)NSString* forSendStr;

@property (nonatomic,assign)double microSecAcc;

@end




@implementation Speaker

-(id)init{
    self = [super init];
    
    self.Base64Index = [NSMutableDictionary dictionaryWithCapacity:10];
    for (int i = 0; i < sizeof(Base64Strs); i++) {
        char chr = Base64Strs[i];
        [self.Base64Index setObject:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%c",chr]];
    }
    
    self.testBaseStr = @"abcdeRRRMMMBBB12345";
    
    
    _forSendStr = [NSString stringWithFormat:@"%s%@%s",starter,self.testBaseStr,ender];
    
    
    self.type = GeneratorTypeSine;
    
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    
    
    
}


-(void)timerHandler{
    //NSLog(@"test:%f",CFAbsoluteTimeGetCurrent());
    
    
    double timeElapse = CFAbsoluteTimeGetCurrent() - self.microSecAcc;
    
    //NSLog(@"timeElapse:%f",timeElapse);
    if (timeElapse <= ONE_SIGNAL_TIME + ONE_GAP_SIGNAL_TIME) {
        
        if (timeElapse < ONE_SIGNAL_TIME) {
            if (self.signalIndex >= [self.forSendStr length]) {
                self.signalIndex = 0;
            }
            NSString* chr = [self.forSendStr substringWithRange:NSMakeRange(self.signalIndex, 1)];
            int chrIndex = [[self.Base64Index objectForKey:chr] intValue];
            self.frequency = FREQUENCE_THRESH + FREQUENCE_STEP/2 + chrIndex*FREQUENCE_STEP;
            
            NSLog(@"send chr:%@ chrIndex:%d .frequency:%f",chr,chrIndex,self.frequency);
            
        }else{
            //信号走完，开始分隔信号
            self.frequency = GAP_FREQUENCE + (rand()/(float)RAND_MAX)*200;
            NSLog(@"send gap frequence:%f",self.frequency);
        }
        
    }else{
        //分隔信号信号走完,开始下一个
        self.signalIndex++;
        self.microSecAcc = CFAbsoluteTimeGetCurrent();
        
        
    }
    
    
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

    
    Float32 *buffer = (Float32 *)audioBufferList->mBuffers[0].mData;
    size_t bufferByteSize = (size_t)audioBufferList->mBuffers[0].mDataByteSize;
    double theta = self.theta;
    double frequency = self.frequency;
    double thetaIncrement = 2.0 * M_PI * frequency / SAMPLE_RATE;
    if (self.type == GeneratorTypeSine)
    {
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
    }
    else if (self.type == GeneratorTypeNoise)
    {
        for (UInt32 frame = 0; frame < frames; frame++)
        {
            buffer[frame] = self.amplitude * ((float)rand()/RAND_MAX) * 2.0f - 1.0f;
        }
    }
    else if (self.type == GeneratorTypeSquare)
    {
        for (UInt32 frame = 0; frame < frames; frame++)
        {
            buffer[frame] = self.amplitude * [EZAudioUtilities SGN:theta];
            theta += thetaIncrement;
            if (theta > 2.0 * M_PI)
            {
                theta -= 4.0 * M_PI;
            }
        }
        self.theta = theta;
    }
    else if (self.type == GeneratorTypeTriangle)
    {
        double samplesPerWavelength = SAMPLE_RATE / self.frequency;
        double ampStep = 2.0 / samplesPerWavelength;
        double step = self.step;
        for (UInt32 frame = 0; frame < frames; frame++)
        {
            if (step > 1.0)
            {
                step = 1.0;
                ampStep = -ampStep;
            }
            else if (step < -1.0)
            {
                step = -1.0;
                ampStep = -ampStep;
            }
            step += ampStep;
            buffer[frame] = self.amplitude * step;
        }
        self.step = step;
    }
    else if (self.type == GeneratorTypeSawtooth)
    {
        double samplesPerWavelength = SAMPLE_RATE / self.frequency;
        double ampStep = 1.0 / samplesPerWavelength;
        double step = self.step;
        for (UInt32 frame = 0; frame < frames; frame++)
        {
            if (step > 1.0)
            {
                step = -1.0;
            }
            step += ampStep;
            buffer[frame] = self.amplitude * step;
        }
        self.step = step;
    }
    
    
    
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
