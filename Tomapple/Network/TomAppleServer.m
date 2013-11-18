//
//  TomAppleServer.m
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "TomAppleServer.h"
#import "UserInformation.h"
@interface TomAppleServer ()
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableArray *connectedSockets;
@end

@implementation TomAppleServer

-(id)init {
    self = [super init];
    if (self) {
        self.users = [NSMutableDictionary dictionary];
        self.connectedSockets = [NSMutableArray array];
    }
    return self;
}


- (void)startBroadCasting {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("dk.tomapple.dispatchqueue.server", 0);
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatchQueue];
    NSError *error = nil;
    if([self.socket acceptOnPort:0 error:&error]){
        self.netService = [[NSNetService alloc]initWithDomain:kDomain type:kDomainType name:@"aName" port:[self.socket localPort]];
        self.netService.delegate = self;
        [self.netService publish];
    } else {
        NSLog(@"could not create a new service, error %@, userInfo: %@", error, [error userInfo]);
    }
}

#pragma mark NSNetServiceDelegate methods
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"published! Domain %@, type %@, port %li", sender.domain, sender.type, (long)sender.port);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
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

#pragma mark - GCDAsyncSocketDelegate methods
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"%s, newSocket %@", __PRETTY_FUNCTION__, newSocket);
    [self.connectedSockets addObject:newSocket];
//    [self setSocket:newSocket];
    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
    [self.connectedSockets removeObject:socket];
//    if (self.socket == socket) {
//        [self.socket setDelegate:nil];
//        [self setSocket:nil];
//    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        [sock readDataToLength:bodyLength withTimeout:-1.0 tag:1];
    } else if (tag == 1) {
        [self parseBody:data];
        [sock readDataToLength:sizeof(uint64_t) withTimeout:30.0 tag:0];
    }
}

#pragma mark - Parse methods
- (uint64_t)parseHeader:(NSData *)data {
    uint64_t headerLength = 0;
    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
    return headerLength;
}

- (void)parseBody:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    UserInformation *receivedUserInformation = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];
    if([self.users objectForKey:receivedUserInformation.userName]){
        [self.users setValue:receivedUserInformation forKey:receivedUserInformation.userName];
    } else {
        [self.users setValue:receivedUserInformation forKey:receivedUserInformation.userName];
    }
    
    [self sendUsers:[NSDictionary dictionaryWithDictionary:self.users]];
}



- (void)sendUsers:(NSDictionary *)users {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //find dud values
    NSDictionary *filteredUsers = [self cleanedUsersFromDictionary:users];
    NSData *packetData = [NSKeyedArchiver archivedDataWithRootObject:filteredUsers];
    NSMutableData *buffer = [[NSMutableData alloc]init];
    //fill buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    /*
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
     */
    for(GCDAsyncSocket *currentSocket in self.connectedSockets){
        [currentSocket writeData:buffer withTimeout:-1.0 tag:0];
    }
}

- (NSDictionary *)cleanedUsersFromDictionary:(NSDictionary *)allUsers {
    NSMutableDictionary *returnValue = [NSMutableDictionary new];
    NSDate *oneMinuteAgo = [[NSDate new] dateByAddingTimeInterval:-20];
    
    for(NSString *key in allUsers){
        UserInformation *currentUser = [allUsers valueForKey:key];
        
        if([currentUser.lastUpdateTime laterDate:oneMinuteAgo] == currentUser.lastUpdateTime){
            //it's new
            [returnValue setValue:currentUser forKey:key];
        } else {
            NSLog(@"dead value found with key: %@", key);
        }
    }
    return [NSDictionary dictionaryWithDictionary:returnValue];
}

@end
