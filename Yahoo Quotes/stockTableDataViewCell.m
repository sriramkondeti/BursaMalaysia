//
//  stockTableDataViewCell.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "stockTableDataViewCell.h"

@implementation stockTableDataViewCell
@synthesize stkCode;

- (IBAction)WatchlistBtnPressed:(id)sender {
    if (_delegate) {
        [_delegate addToWatclistBtnPressed:self];
    }
}
@end
