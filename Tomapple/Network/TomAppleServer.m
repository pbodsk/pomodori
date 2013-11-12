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
@property (nonatomic, strong) AsyncSocket *socket;

@end

@implementation TomAppleServer
- (void)startBroadCasting {
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

#pragma mark AsyncSocketDelegate methods
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self setSocket:newSocket];
    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    UserInformation *proof = [[UserInformation alloc]initWithUserName:@"Peter" remainingTime:180];
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
    NSLog(@"Woooot!! server got data from client: userName: %@, remainingTime %li", proof.userName, (long)proof.remainingTime);
}



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