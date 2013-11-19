//
//  AppDelegate.h
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NetworkControllerDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextFieldCell *timerLabel;
- (IBAction)startButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;
- (IBAction)pauseButtonTapped:(id)sender;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSTableView *usersTable;

@end
