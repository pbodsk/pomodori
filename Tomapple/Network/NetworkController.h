//
//  NetworkController.h
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PomodoriClient.h"
@class UserInformation;
@protocol NetworkControllerDelegate;

@interface NetworkController : NSObject <TomAppleClientDelegate>
- (id) initWithDelegate:(id <NetworkControllerDelegate>)delegate;
- (void) sendUserInformation:(UserInformation *)userInformation;
@end

@protocol NetworkControllerDelegate <NSObject>
@required
- (void)networkController:(NetworkController *)networkController didReceiveUserNames:(NSArray *)userNames andUserInformations:(NSArray *)userInformations;
@end
