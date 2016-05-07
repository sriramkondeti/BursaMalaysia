//
//  VertxConnectionManager.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface VertxConnectionManager : NSObject<SRWebSocketDelegate>


- (void)connect;
- (void)vertxLogin;
- (void)getGainers;
- (void)getLosers;
- (void)getActive;
- (void)vertxSearch : (NSString *)str;
- (void)vertxSearchStkCode : (NSString *)str;



@property(nonatomic,retain)SRWebSocket *webSocket;
+ (VertxConnectionManager *)singleton;


@end
