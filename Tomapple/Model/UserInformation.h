//
//  UserInformation.h
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInformation : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) NSInteger remainingTime;
-(id)initWithUserName:(NSString *)userName remainingTime:(NSInteger)remainingTime;
@end
