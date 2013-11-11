//
//  NetworkController.m
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "NetworkController.h"

#define kDomain @"local."
#define kDomainType @"_tomapple._tcp."

@interface NetworkController ()
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) AsyncSocket *socket;
@property (nonatomic) BOOL servicesFoundBeforeTimeout;

@end

@implementation NetworkController

-(void)browseForNetworks {
    NSLog(@"%s", __PRETTY_FUNCTION__);
/*
    self.netServiceBrowser = [[NSNetServiceBrowser alloc]init];
    self.netServiceBrowser.delegate = self;
    self.servicesFoundBeforeTimeout = NO;
    [self.netServiceBrowser searchForServicesOfType:kDomainType inDomain:kDomain];
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(searchTimeoutReached:) userInfo:nil repeats:NO];
  */  
    [self startBroadcasting];
}

- (void)searchTimeoutReached:(NSTimer *)timer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(! self.servicesFoundBeforeTimeout){
        NSLog(@"shutting down");
        [self.netServiceBrowser stop];
        [self startBroadcasting];
    }
}

- (void)startBroadcasting {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.socket = [[AsyncSocket alloc]initWithDelegate:self];
    NSError *error = nil;
    if([self.socket acceptOnPort:0 error:&error]){
        NSLog(@"port %hu", [self.socket localPort]);
        self.netService = [[NSNetService alloc]initWithDomain:kDomain type:kDomainType name:@"aName" port:[self.socket localPort]];
        self.netService.delegate = self;
        [self.netService publish];
    } else {
        NSLog(@"could not create a new service, error %@, userInfo: %@", error, [error userInfo]);
    }
     
}


#pragma mark NSNetServiceBrowserDelegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.servicesFoundBeforeTimeout = YES;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.servicesFoundBeforeTimeout = YES;
}

#pragma mark NSNetServiceDelegate methods
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"publishing! Domain %@, type %@, port %li", sender.domain, sender.type, (long)sender.port);
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"published! Domain %@, type %@, port %li", sender.domain, sender.type, (long)sender.port);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark AsyncSocketDelegate methods
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}




@end
