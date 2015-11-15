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

#define FREQUENCE_THRESH 10000  //最低声波频率接收阈值
#define FREQUENCE_STEP 120      //声波频率间隔

#define ONE_SIGNAL_TIME 0.08   //每个信号持续的时间
#define ONE_GAP_SIGNAL_TIME 0.06  //分隔信号持续的时间

#define GAP_FREQUENCE FREQUENCE_THRESH - FREQUENCE_STEP*4.5

@interface Speaker : NSObject<EZOutputDelegate,EZOutputDataSource>


-(void)start;
-(void)stop;


@end
