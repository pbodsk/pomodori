//
//  AppController.h
//  Pomodori
//
//  Created by Peter Bødskov on 22/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferenceWindowController;

@interface AppController : NSObject
@property (nonatomic, strong) PreferenceWindowController *preferenceWindowController;
-(IBAction)showPreferencePanel:(id)sender;

@end
