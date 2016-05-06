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


@implementation QuoteViewController
{
    NSMutableArray *localStkcodeArr;
    NSMutableArray *localActiveArr;
    NSMutableArray *localGainerArr;
    NSMutableArray *localLoserArr;
    int btnSelected;




}

-(void)viewDidLoad
{
    localStkcodeArr = [NSMutableArray array];
    localActiveArr = [NSMutableArray array];
    localGainerArr = [NSMutableArray array];
    localLoserArr = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetGainers) name:@"didFinishedgetGainers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetLosers) name:@"didFinishedgetLosers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedgetActive) name:@"didFinishedgetActive" object:nil];
    [_btnActive setSelected:YES];
    [_lblValue setText:@"Last Price"];

    btnSelected = 0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [localStkcodeArr count];
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
    
    cell.lblStkName.text =[temp objectForKey:@"38"];
    
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

    switch (btnSelected) {
        case 0:
            value = [temp objectForKey:@"51"] ;
            cell.lblValue.text = [quantityFormatter stringFromNumber:value];

            break;
           
        default:
            value = [temp objectForKey:@"change"];
            cell.lblValue.text = [priceFormatter stringFromNumber:value];

            break;
    }
    
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

- (IBAction)btnPressed:(UIButton *)sender {
    
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
@end
