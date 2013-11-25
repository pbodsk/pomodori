//
//  TomAppleClient.m
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "PomodoriClient.h"
#import "UserInformation.h"


@interface PomodoriClient ()
@property (nonatomic, weak) id<PomodoriClientDelegate>delegate;
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic) BOOL servicesFoundBeforeTimeout;
@property (nonatomic, strong) UserInformation *userInformation;
@end

@implementation PomodoriClient

- (id)initWithDelegate:(id<PomodoriClientDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)tryToSendUserUserInformation:(UserInformation *)userInformation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.userInformation = userInformation;
    if(self.netService){
        NSLog(@"%s - self.netService already exists", __PRETTY_FUNCTION__);
        //kan vi så bare sende pakken?
        [self sendPacket:userInformation];
    } else {
        self.netServiceBrowser = [[NSNetServiceBrowser alloc]init];
        self.netServiceBrowser.delegate = self;
        self.servicesFoundBeforeTimeout = NO;
        [self.netServiceBrowser searchForServicesOfType:kDomainType inDomain:kDomain];
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(searchTimeoutReached:) userInfo:nil repeats:NO];
    }
}

- (void)searchTimeoutReached:(NSTimer *)timer {
    if(! self.servicesFoundBeforeTimeout){
        NSLog(@"%s", __PRETTY_FUNCTION__);
        [self stopBrowsing];
        [self.delegate performSelector:@selector(timeoutPeriodForClientSearchReached)];
    }
}

- (void)stopBrowsing {
    [self.netServiceBrowser stop];
    self.netServiceBrowser.delegate = nil;
    self.netServiceBrowser = nil;    
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

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.servicesFoundBeforeTimeout = YES;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.netService.delegate = nil;
    self.netService = nil;
    self.netServiceBrowser.delegate = nil;
    self.netServiceBrowser = nil;
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
    if(!self.socket || ![self.socket isConnected] ){
        dispatch_queue_t dispatchQueue = dispatch_queue_create("dk.pomodori.dispatchqueue.client", 0);
        self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatchQueue];
        
        while (! isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            NSError *error = nil;
            
            if([self.socket connectToAddress:address error:&error]){
                NSLog(@"connected");
                isConnected = YES;
            } else if(error) {
                NSLog(@"could not connect, error %@", error);
            }
        }
    } else {
        isConnected = [self.socket isConnected];
        [self sendPacket:self.userInformation];
    }
    return isConnected;
}

#pragma mark AsyncSocketDelegate methods
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [sock readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    [self sendPacket:self.userInformation];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%s, tag: %li", __PRETTY_FUNCTION__, tag);
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        [sock readDataToLength:bodyLength withTimeout:-1.0 tag:1];
    } else if (tag == 1) {
        [self parseBody:data];
        [sock readDataToLength:sizeof(uint64_t) withTimeout:30.0 tag:0];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
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
    NSDictionary *usersFromServer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.delegate client:self didReceiveUsersFromServer:usersFromServer];
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
