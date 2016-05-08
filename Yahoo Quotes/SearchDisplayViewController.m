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
    selectedRow = -1;
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (selectedRow == indexPath.row)
        return 88;
    
    else
        return 44;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return localSearchArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    NSString *tempString = [localSearchArr objectAtIndex:indexPath.row];
    NSMutableDictionary *temp =[[[stockData singleton] qcFeedDataDict] objectForKey:tempString];
    cell.delegate = self;
    cell.lblStkName.text =[temp objectForKey:@"38"];
    cell.stkCode = [temp objectForKey:@"33"];
    value = [temp objectForKey:@"98"] ;
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
            value = [temp objectForKey:@"51"] ;
            cell.lblValue.text = [quantityFormatter stringFromNumber:value];
    
    if ([[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode])
       [ cell.btnWatchlist setEnabled:NO];
    else
        [cell.btnWatchlist setEnabled:YES];

    [cell.btnPriceAlert setHidden:YES];
    return cell;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   
    [[VertxConnectionManager singleton] vertxSearch:_searchBar.text];
    
}

-(void)addToWatclistBtnPressed:(stockTableDataViewCell *)cell
{
    if (![[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode]) {
        
        [[[stockData singleton]watchListStkCodeArr]addObject:cell.stkCode];
        PFObject *sendObject = [PFObject objectWithClassName:@"Watchlist"];
        sendObject[@"Stockcode"] = cell.stkCode;
        [sendObject saveInBackground];
        
      
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Watchlist"
                                      message:[NSString stringWithFormat:@"%@ has been added to Watchlist Successfully", cell.lblStkName.text]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayBtn = [UIAlertAction
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


-(void)doneVertxSearch:(NSNotification *)notification
{
    [_searchBar resignFirstResponder];
    NSDictionary * notificationDict = [notification.userInfo copy];
    localSearchArr = [[notificationDict allKeys]copy];
    [_searchDisplayTableView reloadData];

}
@end
