//
//  stockTableDataViewCell.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface stockTableDataViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblStkName;
@property (strong, nonatomic) IBOutlet UILabel *lblValue;
@property (strong, nonatomic) IBOutlet UIImageView *bgImage;

@end
