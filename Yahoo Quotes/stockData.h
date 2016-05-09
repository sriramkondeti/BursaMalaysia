//
//  stockData.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stockData : NSObject

@property (nonatomic, retain) NSMutableArray *getGainersStkCodeArr;      
@property (nonatomic, retain) NSMutableArray *getLosersStkCodeArr;      
@property (nonatomic, retain) NSMutableArray *getActiveStkCodeArr;      
@property (nonatomic, retain) NSMutableArray *watchListStkCodeArr;      
@property (nonatomic, retain) NSMutableDictionary *qcFeedDataDict;      
@property (nonatomic, retain) NSMutableArray *remoteWatchlistStkCodeArr;      
@property (nonatomic, retain) NSMutableArray *remoteWatchlistid;      
@property (nonatomic, retain) NSMutableArray *remoteStockPrice;      


+(stockData *) singleton;


@end
