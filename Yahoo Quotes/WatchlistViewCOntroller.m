//
//  WatchlistViewCOntroller.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 07/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "WatchlistViewCOntroller.h"
#import "stockData.h"
#import "stockTableDataViewCell.h"
#import <Parse/Parse.h>
#import "VertxConnectionManager.h"
@implementation WatchlistViewCOntroller
{
    int selectedRow;
    

}

-(void)viewDidLoad
{
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"watchlist_enable.png"]
                                     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedRow = -1;
    [_tableview reloadData];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{

        if (selectedRow == indexPath.row)
            return 88;
        
        else
            return 44;

    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    if ([stockData singleton].watchListStkCodeArr.count)
    {
        _tableview .backgroundView = nil;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Add Items to Watchlist.";
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        [messageLabel sizeToFit];
        
        
        _tableview.backgroundView = messageLabel;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        return  0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[stockData singleton].watchListStkCodeArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    stockTableDataViewCell *cell = (stockTableDataViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[stockTableDataViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    NSNumber *value;
    NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
    [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [priceFormatter setMinimumFractionDigits:3];
    [priceFormatter setMaximumFractionDigits:3];
    NSNumberFormatter *quantityFormatter = [NSNumberFormatter new];
    [quantityFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [quantityFormatter setGroupingSeparator:@","];
    [quantityFormatter setGroupingSize:3];
    [quantityFormatter setGeneratesDecimalNumbers:YES];
    NSString *tempString = [[stockData singleton].watchListStkCodeArr objectAtIndex:indexPath.row];
    NSMutableDictionary *temp =[[[stockData singleton] qcFeedDataDict] objectForKey:tempString];
    
    cell.lblStkName.text =[temp objectForKey:@"38"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.stkCode = [temp objectForKey:@"33"];
    [cell.btnWatchlist setTitle:@"Remove" forState:UIControlStateNormal];
    value = [temp objectForKey:@"98"] ;
    cell.lblPrice.text =  [priceFormatter stringFromNumber:value];
    float diffval = [[temp objectForKey:@"98"] floatValue] -[[temp objectForKey:@"51"]floatValue];
    if (diffval>0)
    {
        cell.lblPrice.textColor = [UIColor colorWithRed:(6.0/255.0) green:(220.0/255.0) blue:(167.0/255.0)alpha:1];
        cell.bgImage.image = [UIImage imageNamed:@"ButtonChg_Grn70x30.png"];
    }
    else if (diffval<0)
    {
        cell.lblPrice.textColor = [UIColor colorWithRed:(255.0/255.0) green:(23.0/255.0) blue:(68.0/255.0)alpha:1];
        cell.bgImage.image =[UIImage imageNamed:@"ButtonChg_Red70x30.png"];
    }
    else
        cell.lblPrice.textColor = [UIColor darkGrayColor];
   
            value = [temp objectForKey:@"51"] ;
            cell.lblValue.text = [quantityFormatter stringFromNumber:value];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        
        if (selectedRow == indexPath.row) {
            selectedRow = -1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade ];
            return;
        }
        
        if (selectedRow !=-1) {
            NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        selectedRow = (int)indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

    

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void) priceAlertBtnPressed:(stockTableDataViewCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Price Alert" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    selectedRow = -1;
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Watchlist"];
        [stockData singleton].remoteWatchlistid = [NSMutableArray array];
        [stockData singleton].remoteWatchlistStkCodeArr = [NSMutableArray array];
        [stockData singleton].remoteStockPrice = [NSMutableArray array];
        
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
                PFObject *object = [PFObject objectWithoutDataWithClassName:@"Watchlist"
                                                                   objectId:[[[stockData singleton]remoteWatchlistid]objectAtIndex:[[[stockData singleton]remoteWatchlistStkCodeArr]indexOfObject:cell.stkCode]]];
        object[@"Price"] = [NSString stringWithFormat:@"%.3f",alert.textFields.firstObject.text.floatValue];
        [object saveInBackground];
        [[VertxConnectionManager singleton]getRemoteWatchlistArray];
            }
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [alert addAction:doneAction];
    [alert addAction:cancelAction];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        textField.placeholder = @"Set Price Alert";
    }];
    [alert.view  setNeedsLayout] ;

    [self presentViewController:alert animated:YES completion:nil]; 
}

-(void)addToWatclistBtnPressed:(stockTableDataViewCell *)cell
{
    if ([[stockData singleton].watchListStkCodeArr containsObject:cell.stkCode]) {
        
        [[stockData singleton].watchListStkCodeArr removeObject:cell.stkCode];

        selectedRow = -1;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Watchlist"];
        [stockData singleton].remoteWatchlistid = [NSMutableArray array];
        [stockData singleton].remoteWatchlistStkCodeArr = [NSMutableArray array];
        [stockData singleton].remoteStockPrice = [NSMutableArray array];

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
                PFObject *object = [PFObject objectWithoutDataWithClassName:@"Watchlist"
                                                                   objectId:[[[stockData singleton]remoteWatchlistid]objectAtIndex:[[[stockData singleton]remoteWatchlistStkCodeArr]indexOfObject:cell.stkCode]]];
                [object deleteInBackground];
                [[VertxConnectionManager singleton]getRemoteWatchlistArray];
            }}];
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Watchlist"
                                      message:[NSString stringWithFormat:@"%@ has been Removed from Watchlist.", cell.lblStkName.text]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okbtn = [UIAlertAction
                                actionWithTitle:@"Done"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                    
                                    
                                }];
        
        
        [alert addAction:okbtn];
        
        [self presentViewController:alert animated:YES completion:nil];
        [_tableview reloadData];
    }
}




@end
