//
//  AppDelegate.m
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "AppDelegate.h"

#define kInitialValue 25 * 60

@interface AppDelegate(){
    
}
@property  (nonatomic )NSInteger remainingTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL inPauseMode;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.remainingTime = kInitialValue;
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.inPauseMode = NO;
}

-(void) populateTimerLabelFromRemainingTime:(NSInteger)remainingTime {
    NSInteger minutes = remainingTime / 60;
    NSInteger seconds = remainingTime - (minutes * 60);
    self.timerLabel.title = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
}

- (IBAction)startButtonTapped:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    self.startButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)resetButtonTapped:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self invalidateTimer];
    self.remainingTime = kInitialValue;
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.startButton.hidden = NO;
}

- (IBAction)pauseButtonTapped:(id)sender {
    if(! self.inPauseMode){
        [self invalidateTimer];
        self.inPauseMode = YES;
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        self.inPauseMode = NO;
    }
}

-(void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

-(void)updateTimer:(NSTimer *)timer {
    if(self.remainingTime > 0){
        self.remainingTime -= 1;
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
}

@end
