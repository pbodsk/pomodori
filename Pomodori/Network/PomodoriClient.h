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
@protocol PomodoriClientDelegate;


@interface PomodoriClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate>
- (id)initWithDelegate:(id<PomodoriClientDelegate>)delegate;
- (void)tryToSendUserUserInformation:(UserInformation *)userInformation;
@end

@protocol PomodoriClientDelegate <NSObject>
@required
- (void)timeoutPeriodForClientSearchReached;
- (void)client:(PomodoriClient *)client didReceiveUsersFromServer:(NSDictionary *)usersFromServer;
@end

