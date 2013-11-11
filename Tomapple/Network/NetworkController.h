//
//  NetworkController.h
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>

@interface NetworkController : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate, AsyncSocketDelegate>
- (void) browseForNetworks;
@end
