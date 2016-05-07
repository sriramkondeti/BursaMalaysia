//
//  stockData.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stockData : NSObject

@property (nonatomic, retain) NSMutableArray *getGainersStkCodeArr;      // Major Feed Data store and modify here. Eg:QuoteScreen, Stock Detail and they update constantsly (Real time)
@property (nonatomic, retain) NSMutableArray *getLosersStkCodeArr;      // Major Feed Data store and modify here. Eg:QuoteScreen, Stock Detail and they update constantsly (Real time)
@property (nonatomic, retain) NSMutableArray *getActiveStkCodeArr;      // Major Feed Data store and modify here. Eg:QuoteScreen, Stock Detail and they update constantsly (Real time)
@property (nonatomic, retain) NSMutableArray *watchListStkCodeArr;      // Major Feed Data store and modify here. Eg:QuoteScreen, Stock Detail and they update constantsly (Real time)

@property (nonatomic, retain) NSMutableDictionary *qcFeedDataDict;      // Major Feed Data store and modify here. Eg:QuoteScreen, Stock Detail and they update constantsly (Real time)

+(stockData *) singleton;


@end
