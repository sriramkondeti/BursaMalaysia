//
//  QuoteViewController.m
//  Yahoo Quotes
//
//  Created by Sri Ram on 06/05/2016.
//  Copyright © 2016 Sri Ram. All rights reserved.
//

#import "QuoteViewController.h"
#import "stockTableDataViewCell.h"
#import "stockData.h"
#import <Parse/Parse.h>
#import "VertxConnectionManager.h"

@implementation QuoteViewController
{
    NSMutableArray *localStkcodeArr;
    NSMutableArray *localActiveArr;
    NSMutableArray *localGainerArr;
    NSMutableArray *localLoserArr;
    int btnSelected;
    int selectedRow;
    NSTimer *timer;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    localStkcodeArr = [NSMutableArray array];
    localActiveArr = [NSMutableArray array];
    localGainerArr = [NSMutableArray array];
    localLoserArr = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetGainers) name:@"didFinishedgetGainers" object:nil];//Set Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetLosers) name:@"didFinishedgetLosers" object:nil];//Set Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetActive) name:@"didFinishedgetActive" object:nil];//Set Observer
    [_btnActive setSelected:YES];
    [_lblValue setText:@"Last Price"];
    btnSelected = 0;//Select Active by Default.
    selectedRow = -1;
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"quotes_enable.png"]
                                     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    timer = [NSTimer scheduledTimerWithTimeInterval: 60.0f target: self selector: @selector(checkPriceAlert) userInfo: nil repeats: YES];
  
}

-(void)viewWillAppear:(BOOL)animated
{
    selectedRow = -1;
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

#pragma mark - Tableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [localStkcodeArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //Expand Row.
    if (selectedRow == indexPath.row)
        return 88;
    else
        return 44;
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
    NSString *tempString = [localStkcodeArr objectAtIndex:indexPath.row];
    NSMutableDictionary *temp =[[[stockData singleton] qcFeedDataDict] objectForKey:tempString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate =self;//Set Delegate
    cell.lblStkName.text =[temp objectForKey:@"38"];//Stockname
    cell.stkCode = [temp objectForKey:@"33"];//Stockcode
    value = [temp objectForKey:@"98"];//Stockprice
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
    switch (btnSelected) {
        case 0:
            value = [temp objectForKey:@"51"];//Last adjusted closing price
            cell.lblValue.text = [quantityFormatter stringFromNumber:value];
            break;
        default:
            value = [temp objectForKey:@"change"];//Loss/Gain
            cell.lblValue.text = [priceFormatter stringFromNumber:value];
            break;
    }
    if ([[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode])
        [ cell.btnWatchlist setEnabled:NO];
    else
        [cell.btnWatchlist setEnabled:YES];
    [cell.btnPriceAlert setHidden:YES];//Button Price Alert N/A

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Expand Row
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

}

#pragma mark - Market Movers

-(void)didFinishedgetActive
{
    localStkcodeArr = localActiveArr = [[stockData singleton]getActiveStkCodeArr];
    [_tableView reloadData];
}

-(void)didFinishedgetGainers
{
    localGainerArr = [[stockData singleton]getGainersStkCodeArr];
    
}
-(void)didFinishedgetLosers
{
    localLoserArr = [[stockData singleton]getLosersStkCodeArr];
}

#pragma mark - Button Action

- (IBAction)btnPressed:(UIButton *)sender {
    selectedRow = -1;
    [_btnGainer setSelected:NO];
    [_btnLoser setSelected:NO];
    [_btnActive setSelected:NO];
    btnSelected = (int)sender.tag;
    switch (sender.tag) {
        case 0:
            [_btnActive setSelected:YES];
            localStkcodeArr = localActiveArr;
            [_lblValue setText:@"Last Price"];
            [_tableView reloadData];
            break;
        case 1:
            [_btnGainer setSelected:YES];
            localStkcodeArr = localGainerArr;
            [_lblValue setText:@"Gain"];
            [_tableView reloadData];
            break;
        case 2:
            [_btnLoser setSelected:YES];
            localStkcodeArr = localLoserArr;
            [_lblValue setText:@"Loss"];
            [_tableView reloadData];
            break;
        default:
            break;
    }
}

#pragma mark - Cell Button Delegate

-(void)addToWatclistBtnPressed:(stockTableDataViewCell *)cell
{
    if (![[[stockData singleton]watchListStkCodeArr]containsObject:cell.stkCode]) {
        [[stockData singleton].watchListStkCodeArr addObject:cell.stkCode];
        PFObject *sendObject = [PFObject objectWithClassName:@"Watchlist"];
        sendObject[@"Stockcode"] = cell.stkCode;
        [sendObject saveInBackground];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Watchlist"
                                      message:[NSString stringWithFormat:@"%@ has been added to Watchlist Successfully", cell.lblStkName.text]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okbtn = [UIAlertAction
                                    actionWithTitle:@"Done"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                    }];
        [alert addAction:okbtn];
        [self presentViewController:alert animated:YES completion:nil];
        [_tableView reloadData];
    }
}

-(void)checkPriceAlert
{
    NSString *stkcode;
    NSString *price;
    NSMutableDictionary *tempDict;
    for (int i=0;i<[stockData singleton].remoteStockPrice.count;i++ )
    {
        stkcode = [[stockData singleton].remoteWatchlistStkCodeArr objectAtIndex:i];
            price = [[stockData singleton].remoteStockPrice objectAtIndex:i];
            tempDict = [[[stockData singleton]qcFeedDataDict]objectForKey:stkcode];
            if ([[tempDict objectForKey:@"98"] floatValue] == price.floatValue) {//Send Data to Cloud to check and send Price alert.
                [PFCloud callFunctionInBackground:@"Pricealert" withParameters:@{@"Stockcode": stkcode ,@"Stkname":[tempDict objectForKey:@"38"]} block:
                 ^(id object, NSError * _Nullable error) {
                     if(!error)
                         NSLog(@"success");
                 }];
        }}}

@end
