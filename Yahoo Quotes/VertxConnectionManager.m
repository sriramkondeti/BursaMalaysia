//
//  VertxConnectionManager.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "VertxConnectionManager.h"
#import "stockData.h"
#import <Parse/Parse.h>



@interface VertxConnectionManager()
{
    NSString *_msg;
    NSString *cmdCall;
    NSString *incomingType;
    NSString *incomingMessage;
    NSString *incomingEventId;
    NSString *incomingQid;
    BOOL incomingEnd;
    BOOL incomingHasNext;
    NSString *keepQid;
    NSMutableDictionary *responseDict; // Use for NSNotification Center.
    NSMutableArray *sortedresults;
    NSString *SearchString;


}
@end

@implementation VertxConnectionManager

+ (VertxConnectionManager *)singleton
{
    static VertxConnectionManager * singleton = nil;
    @synchronized(self)
    {
        if(!singleton)
            singleton = [[VertxConnectionManager alloc]init];
       

    }
    return singleton;
    
}

- (id)init
{
    if(self =[super init])
    {
        [self connect];
    }
    return self;
}

- (void)connect
{
        _webSocket.delegate = nil;
        [_webSocket close];
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://nogfv2.itradecimb.com.my/eventbus/websocket"]]]];
        _webSocket.delegate = self;
        [_webSocket open];
}

- (void)reconnect
{
    [self connect]; //reconnect
    
}
- (void) openWebSocket{
    [_webSocket open];
}

-(void) KeepAliveCommand
{
    _msg =@".";
    [_webSocket send:_msg];
    
}

- (void)vertxLogin
{
    cmdCall = @"LOGIN";
    NSMutableDictionary *sendMessage = [[NSMutableDictionary alloc]init];
    [sendMessage setObject:@"session" forKey:@"action"];
    [sendMessage setObject:@"n2n" forKey:@"token"];
    [sendMessage setObject:cmdCall forKey:@"eventId"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendMessage
                                                       options:NSJSONWritingPrettyPrinted error: nil];

    [_webSocket send:jsonData];
    
    
}

-(void)getRemoteWatchlistArray
{
    PFQuery *query = [PFQuery queryWithClassName:@"Watchlist"];
    [stockData singleton].remoteStockPrice =[NSMutableArray array];
    [stockData singleton].remoteWatchlistStkCodeArr = [NSMutableArray array];
    [stockData singleton].remoteWatchlistid = [NSMutableArray array];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            
            for (PFObject *obj in objects)
            {
                [[stockData singleton].remoteWatchlistStkCodeArr addObject:  obj[@"Stockcode"]];
                [[stockData singleton].remoteWatchlistid addObject:obj.objectId];
                if (obj[@"Price"])
                [[stockData singleton].remoteStockPrice addObject:  obj[@"Price"]];
            }
            static dispatch_once_t once;
            dispatch_once(&once, ^ {
                [stockData singleton].watchListStkCodeArr = [stockData singleton].remoteWatchlistStkCodeArr;

            [self getWatchlistDetails];
            });
        }
    }
      ];
}

- (void)getGainers{
    _msg = [NSString stringWithFormat:@"{ \"filter\" : [ { \"field\" : \"38\", \"value\" : \"\", \"comparison\" : \"ne\" }, { \"field\" : \"path\", \"value\" : \"|10|\" }, { \"field\" : \"path\", \"value\" : \"\" } ], \"coll\" : [ \"05\", \"07\" ], \"start\" : 0, \"column\" : [ \"61\", \"55\", \"62\", \"170\", \"56\", \"70\", \"156\", \"57\", \"71\", \"171\", \"241\", \"58\", \"72\", \"59\", \"80\", \"172\", \"123\", \"242\", \"81\", \"100004\", \"68\", \"173\", \"180\", \"82\", \"69\", \"90\", \"174\", \"181\", \"91\", \"237\", \"78\", \"92\", \"182\", \"79\", \"238\", \"183\", \"127\", \"88\", \"change\", \"89\", \"184\", \"98\", \"101\", \"99\", \"changePer\", \"33\", \"41\", \"103\", \"50\", \"51\", \"37\", \"38\", \"60\" ], \"action\" : \"query\", \"sort\" : [ { \"property\" : \"change\", \"direction\" : \"DESC\" } ], \"limit\" : 20, \"exch\" : \"KL\", \"eventId\" : \"getGainers\" }"];
    
    [_webSocket send:_msg];

}

-(void)getLosers{
    _msg = [NSString stringWithFormat:@"{ \"filter\" : [ { \"field\" : \"38\", \"value\" : \"\", \"comparison\" : \"ne\" }, { \"field\" : \"path\", \"value\" : \"|10|\" }, { \"field\" : \"path\", \"value\" : \"\" } ], \"coll\" : [ \"05\", \"07\" ], \"start\" : 0, \"column\" : [ \"61\", \"55\", \"62\", \"170\", \"56\", \"70\", \"156\", \"57\", \"71\", \"171\", \"241\", \"58\", \"72\", \"59\", \"80\", \"172\", \"123\", \"242\", \"81\", \"100004\", \"68\", \"173\", \"180\", \"82\", \"69\", \"90\", \"174\", \"181\", \"91\", \"237\", \"78\", \"92\", \"182\", \"79\", \"238\", \"183\", \"127\", \"88\", \"change\", \"89\", \"184\", \"98\", \"101\", \"99\", \"changePer\", \"33\", \"41\", \"103\", \"50\", \"51\", \"37\", \"38\", \"60\" ], \"action\" : \"query\", \"sort\" : [ { \"property\" : \"change\", \"direction\" : \"ASC\" } ], \"limit\" : 20, \"exch\" : \"KL\", \"eventId\" : \"getLosers\" }"];
    
    [_webSocket send:_msg];

}

-(void)getActive
{
    _msg = [NSString stringWithFormat:@"{ \"filter\" : [ { \"field\" : \"38\", \"value\" : \"\", \"comparison\" : \"ne\" }, { \"field\" : \"path\", \"value\" : \"|10|\" }, { \"field\" : \"path\", \"value\" : \"\" } ], \"coll\" : [ \"05\", \"07\" ], \"start\" : 0, \"column\" : [ \"61\", \"55\", \"62\", \"170\", \"56\", \"70\", \"156\", \"57\", \"71\", \"171\", \"241\", \"58\", \"72\", \"59\", \"80\", \"172\", \"123\", \"242\", \"81\", \"100004\", \"68\", \"173\", \"180\", \"82\", \"69\", \"90\", \"174\", \"181\", \"91\", \"237\", \"78\", \"92\", \"182\", \"79\", \"238\", \"183\", \"127\", \"88\", \"change\", \"89\", \"184\", \"98\", \"101\", \"99\", \"changePer\", \"33\", \"41\", \"103\", \"50\", \"51\", \"37\", \"38\", \"60\" ], \"action\" : \"query\", \"sort\" : [ { \"property\" : \"101\", \"direction\" : \"DESC\" } ], \"limit\" : 20, \"exch\" : \"KL\", \"eventId\" : \"getActive\" }"];
    
    [_webSocket send:_msg];
}

-(void)getWatchlistDetails
{
    
    
    NSArray *collumnArr = [NSArray arrayWithObjects:@"38",@"33",@"98",@"51", nil];
    NSMutableDictionary *sendMessage = [[NSMutableDictionary alloc]init];
    [sendMessage setObject:@"query" forKey:@"action"];
    [sendMessage setObject:@[@"05"] forKey:@"coll"];
    
    [sendMessage setObject:collumnArr forKey:@"column"];
    
    NSMutableArray *filterArr = [[NSMutableArray alloc]init];
    NSMutableDictionary *filterDict = [[NSMutableDictionary alloc]init];
    [filterDict setObject:@"38" forKey:@"field"];
    [filterDict setObject:@"ne" forKey:@"comparison"];
    [filterDict setObject:@"" forKey:@"value"];
    [filterArr addObject:[filterDict copy]];
    
    [filterDict setObject:@"33" forKey:@"field"];
    [filterDict setObject:@"in" forKey:@"comparison"];
    [filterDict setObject:[[stockData singleton]watchListStkCodeArr] forKey:@"value"];
    [filterArr addObject:[filterDict copy]];
    
    [sendMessage setObject:filterArr forKey:@"filter"];
     [sendMessage setObject:@"vertxGetDetails" forKey:@"eventId"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendMessage
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    [_webSocket send:jsonData];

}


- (void)vertxSearch : (NSString *)str
{
    
 
    
    _msg = [NSString stringWithFormat:@"{\"action\":\"query\",\"coll\":[\"05\"],\"start\":0,\"limit\":22,\"column\":[\"38\",\"36\",\"98\",\"48\",\"51\",\"134\",\"135\",\"50\",\"40\",\"35\",\"39\",\"139\",\"103\",\"238\",\"56\",\"57\",\"101\",\"153\",\"156\",\"49\",\"245\",\"140\",\"141\",\"142\",\"244\",\"243\",\"55\",\"52\",\"104\",\"99\",\"132\",\"54\",\"102\",\"41\",\"buyRate\",\"33\",\"58\",\"68\",\"78\",\"88\",\"change\",\"changePer\",\"170\",\"171\",\"172\",\"173\",\"174\",\"58\",\"59\",\"60\",\"61\",\"62\",\"68\",\"69\",\"70\",\"71\",\"72\",\"88\",\"89\",\"90\",\"91\",\"92\",\"78\",\"79\",\"80\",\"81\",\"82\",\"180\",\"181\",\"182\",\"183\",\"184\"],\"filter\":[{\"field\":\"38\",\"value\":\"\",\"type\":\"string\",\"comparison\":\"ne\"},{\"field\":\"131\",\"value\":[\"MY\",\"KL\",\"JKD\",\"SID\",\"BKD\",\"OD\",\"ND\",\"AD\",\"HKD\"],\"comparison\":\"in\"},{\"field\":\"path\",\"value\":\"|10|\"},{\"field\":\"38\",\"value\":\"(?i:^%@[\\\\s\\\\S]*)\",\"type\":\"string\",\"comparison\":\"regex\"}],\"sort\":[{\"property\":\"stkCode\",\"direction\":\"ASC\"}],\"eventId\":\"vertxSearch\"}",str];
    
    [_webSocket send:_msg];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:message options:0 error:&localError];
    incomingType    = [ parsedObject objectForKey:@"type"];
    incomingEventId = [ parsedObject objectForKey:@"eventId"];
    incomingQid     = [[parsedObject objectForKey:@"qId"]stringValue];
    incomingMessage = [ parsedObject objectForKey:@"message"];
    incomingHasNext = [[parsedObject objectForKey:@"hasNext"]boolValue];
    incomingEnd     = [[parsedObject objectForKey:@"end"]boolValue];
    
    
    if([incomingType isEqualToString:@"q"])
    {
    if(incomingEventId) //Header coming in
    {
        keepQid = incomingEventId;
    }
        else
        {
     if([keepQid isEqualToString:@"getGainers"])
    {
        if(!responseDict)
        {
            responseDict = [NSMutableDictionary dictionary];
            sortedresults = [NSMutableArray array];
        }
        
        if(incomingEnd)
        {
            
            responseDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:[[stockData singleton]getGainersStkCodeArr],@"sortedresults", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishedgetGainers" object:self userInfo:responseDict];
            responseDict = nil;
            incomingHasNext = false;
            keepQid = nil;
            sortedresults=nil;
            
            return;
        }
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[parsedObject objectForKey:@"data"]]; //**important to set it to MutableDict for mod when receive new data.
        [[[stockData singleton]qcFeedDataDict] setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]]; //For QCDataCenter
        [[[stockData singleton]getGainersStkCodeArr] addObject:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        tempDict = nil;
    }
    else if([keepQid isEqualToString:@"getLosers"])
    {
        if(!responseDict)
        {
            responseDict = [NSMutableDictionary dictionary];
            sortedresults = [NSMutableArray array];
        }
        
        
        if(incomingEnd)
        {
            responseDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:[[stockData singleton]getLosersStkCodeArr],@"sortedresults", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishedgetLosers" object:self userInfo:responseDict];
            responseDict = nil;
            incomingHasNext = false;
            keepQid = nil;
            sortedresults=nil;
            
            return;
        }
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[parsedObject objectForKey:@"data"]];
        [[[stockData singleton]qcFeedDataDict] setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        
        [[[stockData singleton]getLosersStkCodeArr] addObject:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        tempDict = nil;
    }
    
    else if([keepQid isEqualToString:@"getActive"])
    {
        if(!responseDict)
        {
            responseDict = [NSMutableDictionary dictionary];
            sortedresults = [NSMutableArray array];
        }
        
        if(incomingEnd)
        {
            responseDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:[[stockData singleton]getActiveStkCodeArr],@"sortedresults", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishedgetActive" object:self userInfo:responseDict];
            responseDict = nil;
            incomingHasNext = false;
            keepQid = nil;
            sortedresults=nil;
            
            return;
        }
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[parsedObject objectForKey:@"data"]];
        [[[stockData singleton]qcFeedDataDict] setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]]; //For QCDataCenter
        [[[stockData singleton]getActiveStkCodeArr] addObject:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        tempDict = nil;
    }
            
    else if ([keepQid isEqualToString:@"vertxSearch"])
    {
        if(!responseDict)
            responseDict = [NSMutableDictionary dictionary];
        if(incomingEnd)
        {
            NSMutableDictionary *notificationData = [NSMutableDictionary dictionaryWithDictionary:responseDict];
            if ([responseDict count]>0)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"doneVertxSearch" object:self userInfo:notificationData];
            responseDict = nil;
            incomingHasNext = false;
            keepQid = nil;
            return;
        }
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[parsedObject objectForKey:@"data"]];
        [[[stockData singleton]qcFeedDataDict] setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        [responseDict setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        tempDict = nil;
    }
            
    else if ([keepQid isEqualToString:@"vertxGetDetails"])
    {
        if(!responseDict)
            responseDict = [NSMutableDictionary dictionary];
        if(incomingEnd)
        {
            responseDict = nil;
            NSMutableDictionary *notificationData = [NSMutableDictionary dictionaryWithDictionary:responseDict];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveStockDetails" object:self userInfo:notificationData];

            incomingHasNext = false;
            keepQid = nil;
            return;
        }
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[parsedObject objectForKey:@"data"]];
        [[[stockData singleton]qcFeedDataDict] setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        [responseDict setObject:tempDict forKey:[[parsedObject objectForKey:@"data"]objectForKey:@"33"]];
        tempDict = nil;
    }
    }
    }
}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self vertxLogin];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(KeepAliveCommand) userInfo:nil repeats:YES];
    [self getGainers];
    [self getLosers];
    [self getActive];

    
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    _webSocket = nil;
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    _webSocket = nil;
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
}
@end
