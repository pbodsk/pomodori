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

@interface NetworkController ()
@property (nonatomic, strong) TomAppleClient *client;
@property (nonatomic, strong) TomAppleServer *server;

@end

@implementation NetworkController

-(id)init {
    self = [super init];
    if (self) {
        self.client = [[TomAppleClient alloc]initWithDelegate:self];
        self.server = [TomAppleServer new];
    }
    return self;
}

-(void)browseForNetworks {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.client browseForNetworks];
}

- (void)broadcastServer {
    [self startBroadcasting];
}

- (void)startBroadcasting {
}

#pragma mark TomAppleClientDelegate methods
- (void)timeoutPeriodForClientSearchReached {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.server startBroadCasting];
    [self.client browseForNetworks];
}

@end
