//
//  TomAppleClient.m
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "TomAppleClient.h"
#import "UserInformation.h"


@interface TomAppleClient ()
@property (nonatomic, weak) id<TomAppleClientDelegate>delegate;
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) AsyncSocket *socket;
@property (nonatomic) BOOL servicesFoundBeforeTimeout;
@end

@implementation TomAppleClient

- (id)initWithDelegate:(id<TomAppleClientDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)browseForNetworks {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.netServiceBrowser = [[NSNetServiceBrowser alloc]init];
    self.netServiceBrowser.delegate = self;
    self.servicesFoundBeforeTimeout = NO;
    [self.netServiceBrowser searchForServicesOfType:kDomainType inDomain:kDomain];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(searchTimeoutReached:) userInfo:nil repeats:NO];
}

- (void)searchTimeoutReached:(NSTimer *)timer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(! self.servicesFoundBeforeTimeout){
        [self.delegate performSelector:@selector(timeoutPeriodForClientSearchReached)];
    }
}

#pragma mark NSNetServiceBrowserDelegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.servicesFoundBeforeTimeout = YES;
    self.netService = aNetService;
    self.netService.delegate = self;
    [self.netService resolveWithTimeout:30];
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

#pragma mark NSNetServiceDelegateMethods
- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if([self connectWithService:service]){
        NSLog(@"connected to service");
    } else {
        NSLog(@"could not connnect to service");
    }
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark connect to service methods
- (BOOL)connectWithService:(NSNetService *)service {
    BOOL isConnected = NO;
    NSArray *addresses = [[service addresses]mutableCopy];
    if(!self.socket || [self.socket isConnected] ){
        self.socket = [[AsyncSocket alloc]initWithDelegate:self];
        while (! isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            NSError *error = nil;
            
            if([self.socket connectToAddress:address error:&error]){
                isConnected = YES;
            } else if(error) {
                NSLog(@"could not connect, error %@", error);
            }
        }
    } else {
        isConnected = [self.socket isConnected];
    }
    return isConnected;
}

#pragma mark AsyncSocketDelegate methods
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [sock readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    UserInformation *proof = [[UserInformation alloc]initWithUserName:@"Pia" remainingTime:1800];
    [self sendPacket:proof];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        [sock readDataToLength:bodyLength withTimeout:-1.0 tag:1];
    } else if (tag == 1) {
        [self parseBody:data];
        [sock readDataToLength:sizeof(uint64_t) withTimeout:30.0 tag:0];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock; {
    [sock setDelegate:nil];
    [self setSocket:nil];
}

#pragma mark parse methods
- (uint64_t)parseHeader:(NSData *)data {
    uint64_t headerLength = 0;
    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
    return headerLength;
}

- (void)parseBody:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    UserInformation *proof = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];
    NSLog(@"Woooot!! client got data from server: userName: %@, remainingTime %li", proof.userName, (long)proof.remainingTime);
}

#pragma mark send method
- (void)sendPacket:(UserInformation *)packet {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableData *packetData = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    NSMutableData *buffer = [[NSMutableData alloc]init];
    //fill buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}




@end
