//
//  PreferenceWindowController.m
//  Pomodori
//
//  Created by Peter Bødskov on 22/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "PreferenceWindowController.h"

NSString * const PMDRPrefUserNameKey = @"PMDRPrefUserNameKey";
NSString * const PMDRPrefPomodorLengthKey = @"PMDRPrefPomodorLengthKey";

@interface PreferenceWindowController ()

@end

@implementation PreferenceWindowController

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.userNameTextField.stringValue = [[NSUserDefaults standardUserDefaults]objectForKey:PMDRPrefUserNameKey];
    self.pomodoroLengthTextField.stringValue = [[NSUserDefaults standardUserDefaults]objectForKey:PMDRPrefPomodorLengthKey];
}

#pragma mark NSTextFieldDelegate methods


- (IBAction)userNameEntered:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *newUserName = self.userNameTextField.stringValue;
    [[NSUserDefaults standardUserDefaults]setObject:newUserName forKey:PMDRPrefUserNameKey];
}

- (IBAction)pomodoroLengthEntered:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *newPomodoroLength = self.pomodoroLengthTextField.stringValue;
    [[NSUserDefaults standardUserDefaults]setObject:newPomodoroLength forKey:PMDRPrefPomodorLengthKey];
}
@end
