//
//  TomAppleClient.h
//  Tomapple
//
//  Created by Peter Bødskov on 12/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>

@protocol TomAppleClientDelegate <NSObject>
@required
- (void)timeoutPeriodForClientSearchReached;
@end

@interface TomAppleClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, AsyncSocketDelegate>
- (id)initWithDelegate:(id<TomAppleClientDelegate>)delegate;
- (void)browseForNetworks;
@end