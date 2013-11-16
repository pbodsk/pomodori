//
//  NetworkController.m
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "NetworkController.h"
#import "TomAppleServer.h"
#import "TomAppleClient.h"
#import "UserInformation.h"

@interface NetworkController ()
@property (nonatomic, weak) id<NetworkControllerDelegate>delegate;
@property (nonatomic, strong) TomAppleClient *client;
@property (nonatomic, strong) TomAppleServer *server;
@property (nonatomic, strong) UserInformation *userInformation;

@end

@implementation NetworkController

-(id)initWithDelegate:(id<NetworkControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.client = [[TomAppleClient alloc]initWithDelegate:self];
        self.server = [[TomAppleServer alloc]init];
    }
    return self;
}

- (void) sendUserInformation:(UserInformation *)userInformation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.userInformation = userInformation;
    [self.client tryToSendUserUserInformation:self.userInformation];
}

#pragma mark TomAppleClientDelegate methods
- (void)timeoutPeriodForClientSearchReached {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.server startBroadCasting];
    [self.client tryToSendUserUserInformation:self.userInformation];
}

- (void)client:(TomAppleClient *)client didReceiveUsersFromServer:(NSDictionary *)usersFromServer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.delegate networkController:self didReceiveUsersFromServer:usersFromServer];
}
@end
