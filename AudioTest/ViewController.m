//
//  ViewController.m
//  AudioTest
//
//  Created by Mac on 15/11/15.
//  Copyright © 2015年 lookfeel. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#import "Speaker.h"
#import "SoundScaner.h"

@interface ViewController ()

@property(nonatomic,strong)Speaker* speaker;
@property(nonatomic,strong)SoundScaner* scaner;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.speaker = [Speaker new];
    
    self.scaner = [SoundScaner new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)speakerStart:(id)sender{
    [self.speaker start];
}

-(IBAction)speakerStop:(id)sender{
    [self.speaker stop];
    
}

-(IBAction)scanerStart:(id)sender{
    [self.scaner start];
}

-(IBAction)scanerStop:(id)sender{
    [self.scaner stop];
    
}

@end
