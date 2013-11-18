//
//  UserInformation.m
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "UserInformation.h"

@implementation UserInformation
-(id)initWithUserName:(NSString *)userName remainingTime:(NSInteger)remainingTime {
    self = [super init];
    if(self) {
        self.userName = userName;
        self.remainingTime = remainingTime;
        self.lastUpdateTime = [NSDate new];
    }
    return self;
}

#pragma mark NSCoding methods
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeInteger:self.remainingTime forKey:@"remainingTime"];
    [coder encodeObject:self.lastUpdateTime forKey:@"lastUpdateTime"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.remainingTime = [decoder decodeIntegerForKey:@"remainingTime"];
        self.lastUpdateTime = [decoder decodeObjectForKey:@"lastUpdateTime"];
    }
    return self;
}

@end
