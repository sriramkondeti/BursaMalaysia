//
//  SearchDisplayViewController.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 07/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "stockTableDataViewCell.h"

@interface SearchDisplayViewController : UITableViewController<UITableViewDelegate,stockTableDataViewCellDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *searchDisplayTableView;

@end
