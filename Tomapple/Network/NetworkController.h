//
//  NetworkController.h
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TomAppleClient.h"
#import "TomAppleServerDelegate.h"


@interface NetworkController : NSObject <TomAppleClientDelegate, TomAppleServerDelegate>
- (void) browseForNetworks;
- (void) broadcastServer;
@end
