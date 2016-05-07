//
//  stockTableDataViewCell.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol stockTableDataViewCellDelegate;

@interface stockTableDataViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblStkName;
@property (strong, nonatomic) IBOutlet UILabel *lblValue;
@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) NSString * stkCode;

@property (nonatomic,retain) id <stockTableDataViewCellDelegate> delegate;

- (IBAction)WatchlistBtnPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnWatchlist;

@end

@protocol stockTableDataViewCellDelegate <NSObject>

-(void)addToWatclistBtnPressed:(stockTableDataViewCell *)cell;

@end
