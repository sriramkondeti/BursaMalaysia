//
//  stockData.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "stockData.h"

@implementation stockData :NSObject
@synthesize getActiveStkCodeArr,getGainersStkCodeArr,getLosersStkCodeArr,qcFeedDataDict,watchListStkCodeArr,remoteWatchlistStkCodeArr,remoteWatchlistid,remoteStockPrice;

+ (stockData *)singleton
{
    //Intialize as Singleton.
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
        qcFeedDataDict    = [NSMutableDictionary dictionary];//Save each Stock data into a Dictionary.
        getLosersStkCodeArr = [NSMutableArray array];//Market Movers - Losers Stock Array.
        getGainersStkCodeArr = [NSMutableArray array];//Market Movers - Gainers Stocks Array.
        getActiveStkCodeArr = [NSMutableArray array];//Market Movers - Active Stocks Array.
        watchListStkCodeArr = [NSMutableArray array];//Local Watchlist Stock Code Array.
        remoteWatchlistStkCodeArr = [NSMutableArray array];//Cloud Watchlist Stock Code Array.
        remoteWatchlistid = [NSMutableArray array];//Cloud Watchlist Stock ID Array.
        remoteStockPrice = [NSMutableArray array];//Cloud Watchlist Stock Price Array.
    }
    return self;
}

@end
