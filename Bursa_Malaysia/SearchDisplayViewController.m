//
//  SearchDisplayViewController.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 07/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "SearchDisplayViewController.h"
#import "VertxConnectionManager.h"
#import "stockTableDataViewCell.h"
#import "stockData.h"
#import <Parse/Parse.h>

@implementation SearchDisplayViewController
{
    NSMutableArray *localSearchArr;
    int selectedRow;
}

-(void)viewDidLoad{
    
    self.title  =@"Search";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneVertxSearch:) name:@"doneVertxSearch" object:nil];
    selectedRow = -1;//Invalidates the selected Row.
}



#pragma mark - Tableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (localSearchArr)
    {
        _searchDisplayTableView .backgroundView = nil;
        _searchDisplayTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No Results.";
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        [messageLabel sizeToFit];
        _searchDisplayTableView.backgroundView = messageLabel;
        _searchDisplayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return  0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (selectedRow == indexPath.row)
        return 88;//Expanded Row size
    
    else
        return 44;//Default size
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return localSearchArr.count;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    stockTableDataViewCell *cell = (stockTableDataViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[stockTableDataViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;//Custom Cell Intialization.
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
    NSString *tempString = [localSearchArr objectAtIndex:indexPath.row];
    NSMutableDictionary *temp =[[[stockData singleton] qcFeedDataDict] objectForKey:tempString];
    cell.delegate = self;//Set Delegate.
    cell.lblStkName.text =[temp objectForKey:@"38"];//Stock Name
    cell.stkCode = [temp objectForKey:@"33"];//Stock Code
    value = [temp objectForKey:@"98"];// Price.
    cell.lblPrice.text =  [priceFormatter stringFromNumber:value];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            value = [temp objectForKey:@"51"] ;//Last adjusted closing price
            cell.lblValue.text = [quantityFormatter stringFromNumber:value];
    
    if ([[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode])
       [ cell.btnWatchlist setEnabled:NO];
    else
        [cell.btnWatchlist setEnabled:YES];

    [cell.btnPriceAlert setHidden:YES];//Price alert button N/A
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Expand Rows
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

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Send the Search text to vertx for results.
    [[VertxConnectionManager singleton] vertxSearch:_searchBar.text];
}

-(void)doneVertxSearch:(NSNotification *)notification
{
    //Triggered from Push Notification.
    [_searchBar resignFirstResponder];
    NSDictionary * notificationDict = [notification.userInfo copy];
    localSearchArr = [[notificationDict allKeys]copy];
    [_searchDisplayTableView reloadData];
    
}

#pragma mark - Watchlist Delegate
-(void)addToWatclistBtnPressed:(stockTableDataViewCell *)cell
{
    if (![[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode]) {
        [[[stockData singleton]watchListStkCodeArr]addObject:cell.stkCode];//Save Locally
        PFObject *sendObject = [PFObject objectWithClassName:@"Watchlist"];//Save in the cloud.
        sendObject[@"Stockcode"] = cell.stkCode;
        [sendObject saveInBackground];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Watchlist"
                                      message:[NSString stringWithFormat:@"%@ has been added to Watchlist Successfully", cell.lblStkName.text]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okayBtn =      [UIAlertAction
                             actionWithTitle:@"Done"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                             }];
        [alert addAction:okayBtn];
        [self presentViewController:alert animated:YES completion:nil];
        [_searchDisplayTableView reloadData];
    }
}


@end
