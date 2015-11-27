//
//  Speaker.h
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudio.h"


#define SAMPLE_RATE 44100 //采样率

#define FREQUENCE_THRESH 12000  //最低声波频率接收阈值
#define FREQUENCE_STEP 50      //声波频率间隔

#define ONE_SIGNAL_TIME 0.06   //每个信号持续的时间
#define ONE_GAP_SIGNAL_TIME 0.08  //分隔信号持续的时间

#define GAP_FREQUENCE 16000

extern unsigned char Base64Strs[];


extern char* starter;
extern char* ender;



typedef NS_ENUM(NSUInteger, GeneratorType)
{
    GeneratorTypeSine,
    GeneratorTypeSquare,
    GeneratorTypeTriangle,
    GeneratorTypeSawtooth,
    GeneratorTypeNoise,
};


@interface Speaker : NSObject<EZOutputDelegate,EZOutputDataSource>


-(void)start;
-(void)stop;


@end
