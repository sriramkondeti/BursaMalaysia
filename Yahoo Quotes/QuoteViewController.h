//
//  QuoteViewController.h
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteViewController : UIViewController<UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnActive;
@property (strong, nonatomic) IBOutlet UIButton *btnGainer;
@property (strong, nonatomic) IBOutlet UIButton *btnLoser;
@property (strong, nonatomic) IBOutlet UILabel *lblValue;

- (IBAction)btnPressed:(id)sender;
@end
