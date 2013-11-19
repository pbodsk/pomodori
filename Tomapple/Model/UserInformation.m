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

- (NSString *)presentationStringForPomodoroStatus:(UserInformationPomodoroStatus)status {
    NSString *returnValue;
    switch (status) {
        case UserInformationPomodoroStatusActive:
            returnValue = @"active";
            break;
        case UserInformationPomodoroStatusPaused:
            returnValue = @"paused";
            break;
        default:
            returnValue = @"done";
            break;
    }
    return returnValue;
}

#pragma mark NSCoding methods
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeInteger:self.remainingTime forKey:@"remainingTime"];
    [coder encodeObject:self.lastUpdateTime forKey:@"lastUpdateTime"];
    [coder encodeInteger:self.pomodoroStatus forKey:@"pomodoroStatus"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.remainingTime = [decoder decodeIntegerForKey:@"remainingTime"];
        self.lastUpdateTime = [decoder decodeObjectForKey:@"lastUpdateTime"];
        self.pomodoroStatus = [decoder decodeIntegerForKey:@"pomodoroStatus"];
    }
    return self;
}

@end
