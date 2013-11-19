//
//  UserInformation.h
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserInformationPomodoroStatus) {
    UserInformationPomodoroStatusActive,
    UserInformationPomodoroStatusPaused,
    UserInformationPomodoroStatusDone
};

@interface UserInformation : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) NSInteger remainingTime;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic) UserInformationPomodoroStatus pomodoroStatus;
-(id)initWithUserName:(NSString *)userName remainingTime:(NSInteger)remainingTime;
- (NSString *)presentationStringForPomodoroStatus:(UserInformationPomodoroStatus)status;
@end
