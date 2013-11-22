//
//  AppController.m
//  Pomodori
//
//  Created by Peter Bødskov on 22/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "AppController.h"
#import "PreferenceWindowController.h"

@implementation AppController
+ (void)initialize {
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[[NSHost currentHost]name] forKey:PMDRPrefUserNameKey];
    [defaultValues setObject:@"25" forKey:PMDRPrefPomodorLengthKey];
    [[NSUserDefaults standardUserDefaults]registerDefaults:defaultValues];
    NSLog(@"%s - registered", __PRETTY_FUNCTION__);
}

-(IBAction)showPreferencePanel:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (! self.preferenceWindowController) {
        self.preferenceWindowController = [[PreferenceWindowController alloc]init];
    }
    [self.preferenceWindowController showWindow:self];
}

@end
