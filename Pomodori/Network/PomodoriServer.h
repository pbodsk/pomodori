//
//  TomAppleServer.h
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>


@interface PomodoriServer : NSObject <NSNetServiceDelegate, GCDAsyncSocketDelegate>
- (void)startBroadCasting;
@end

