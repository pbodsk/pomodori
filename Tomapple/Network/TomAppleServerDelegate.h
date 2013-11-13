//
//  TomAppleServerDelegate.h
//  Tomapple
//
//  Created by Peter Bødskov on 13/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TomAppleServer;

@protocol TomAppleServerDelegate <NSObject>
- (void)server:(TomAppleServer *)server containsUsers:(NSDictionary *)containedUsers;
@end
