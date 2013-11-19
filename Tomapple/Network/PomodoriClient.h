//
//  TomAppleClient.h
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
@class UserInformation;
@protocol TomAppleClientDelegate;


@interface PomodoriClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate>
- (id)initWithDelegate:(id<TomAppleClientDelegate>)delegate;
- (void)tryToSendUserUserInformation:(UserInformation *)userInformation;
@end

@protocol TomAppleClientDelegate <NSObject>
@required
- (void)timeoutPeriodForClientSearchReached;
- (void)client:(PomodoriClient *)client didReceiveUsersFromServer:(NSDictionary *)usersFromServer;
@end

