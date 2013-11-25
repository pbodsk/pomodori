//
//  PreferenceWindowController.h
//  Pomodori
//
//  Created by Peter Bødskov on 22/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const PMDRPrefUserNameKey;
extern NSString * const PMDRPrefPomodorLengthKey;

@interface PreferenceWindowController : NSWindowController <NSTextFieldDelegate>

@property (strong) IBOutlet NSTextField *userNameTextField;
@property (strong) IBOutlet NSTextField *pomodoroLengthTextField;
- (IBAction)userNameEntered:(id)sender;
- (IBAction)pomodoroLengthEntered:(id)sender;
- (IBAction)updatePressed:(id)sender;
@end
