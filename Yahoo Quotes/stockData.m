//
//  stockData.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "stockData.h"

@implementation stockData :NSObject
@synthesize getActiveStkCodeArr,getGainersStkCodeArr,getLosersStkCodeArr,qcFeedDataDict,watchListStkCodeArr;

+ (stockData *)singleton
{
    static stockData * singleton = nil;
    @synchronized(self)
    {
        if (!singleton) {
            singleton = [[stockData alloc]init];
        }
    }
    return singleton;
}

- (id)init
{
    if(self = [super init])
    {
        qcFeedDataDict    = [NSMutableDictionary dictionary];
        getLosersStkCodeArr = [NSMutableArray array];
        getGainersStkCodeArr = [NSMutableArray array];
        getActiveStkCodeArr = [NSMutableArray array];
        watchListStkCodeArr = [NSMutableArray array];
        
    }
    return self;
}


@end
