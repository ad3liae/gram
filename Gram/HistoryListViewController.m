//
//  HistoryListViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "HistoryListViewController.h"
#import "BarCodeViewController.h"
#import "UITabBarWithAdController.h"
#import "ReaderViewController.h"
#import "DetailViewController.h"


@interface HistoryListViewController ()
{
    UIBarButtonItem *rightItem;
    UIBarButtonItem *leftItem;
    NSMutableArray *history;
    NSArray *listContent; // The master content.
	NSMutableArray *filteredListContent; // The content filtered as a result of a search.
	// The saved state of the search UI if a memory warning removed the view.
    NSString *savedSearchTerm;
    NSInteger savedScopeButtonIndex;
    BOOL searchWasActive;
    CGRect frame;
}

@end

@implementation HistoryListViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    frame = [self.tableView frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    rightItem = self.navigationItem.rightBarButtonItem;
    leftItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    
    // create a filtered list that will contain products for the search results table.
	filteredListContent = [NSMutableArray arrayWithCapacity:[history count]];
    
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (savedSearchTerm)
	{
        [self.searchDisplayController setActive:searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        savedSearchTerm = nil;
    }
}

- (void)editButtonSelected:(id)sender
{
    if (self.tableView.editing)
    {
        [self.tableView setEditing:NO animated:YES];
        [leftItem setTitle:@"編集"];
        
        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [leftItem setTitle:@"完了"];
        
        UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemTrash target:self action:@selector(tapDelete:)];
        deleteButtonItem.tintColor = [UIColor redColor];
        [self.navigationItem setRightBarButtonItem:deleteButtonItem animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"履歴";
    self.navigationItem.rightBarButtonItem = rightItem;
    leftItem.target = self;
    leftItem.action = @selector(editButtonSelected:);
    self.navigationItem.leftBarButtonItem = leftItem;
    history = [GramContext get]->history;
    
    [self.tableView reloadData];
    
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    tabBar.delegate = self;
    
    if (tabBar.bannerIsVisible)
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93 -  49)];
        [self.searchDisplayController.searchResultsTableView setFrame:CGRectMake(frame.origin.x,
                                                                                 frame.origin.y + 44,
                                                                                 frame.size.width,
                                                                                 frame.size.height - 93 -  49 - 44)];
    }
    else
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93)];
        [self.searchDisplayController.searchResultsTableView setFrame:CGRectMake(frame.origin.x,
                                                                                 frame.origin.y + 44,
                                                                                 frame.size.width,
                                                                                 frame.size.height - 93 - 44)];
    }
    
    //NSLog(@"%f", self.searchDisplayController.searchResultsTableView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.viewControllers = [NSArray arrayWithObject:self];
    
    //NSLog(@"%f", self.searchDisplayController.searchResultsTableView.frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.delegate == self)
    {
        tabBar.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:YES];
    
    if (editing)
    {
        //self.editButtonItem.title = @"完了";
        UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                          UIBarButtonSystemItemTrash target:self action:@selector(tapDelete:)];
        [self.navigationItem setRightBarButtonItem:deleteButtonItem animated:YES];
    }
    else
    {
        //self.editButtonItem.title = @"編集";
        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    }
}

- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return @"削除";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UIImage *)listIconFromLabel:(NSString *)label
{
    UIImage *image = nil;
    if ([label isEqualToString:@"URL"])
    {
        image = [UIImage imageNamed:@"listicon_url.png"];
    }
    else if ([label isEqualToString:@"場所"])
    {
        image = [UIImage imageNamed:@"listicon_map.png"];
    }
    else if ([label isEqualToString:@"連絡先"])
    {
        image = [UIImage imageNamed:@"listicon_address.png"];
    }
    else if ([label isEqualToString:@"イベント"])
    {
        image = [UIImage imageNamed:@"listicon_event.png"];
    }
    else if ([label isEqualToString:@"電話番号"])
    {
        image = [UIImage imageNamed:@"listicon_tel.png"];
    }
    else if ([label isEqualToString:@"SMS"])
    {
        image = [UIImage imageNamed:@"listicon_sms.png"];
    }
    else if ([label isEqualToString:@"Eメール"])
    {
        image = [UIImage imageNamed:@"listicon_email.png"];
    }
    else if ([label isEqualToString:@"ツイッター"])
    {
        image = [UIImage imageNamed:@"listicon_twitter.png"];
    }
    else if ([label isEqualToString:@"フェイスブック"])
    {
        image = [UIImage imageNamed:@"listicon_facebook.png"];
    }
    else if ([label isEqualToString:@"Wi-Fiネットワーク"])
    {
        image = [UIImage imageNamed:@"listicon_wifi.png"];
    }
    else if ([label isEqualToString:@"テキスト"])
    {
        image = [UIImage imageNamed:@"listicon_text.png"];
    }
    else if ([label isEqualToString:@"クリップボードの内容"])
    {
        image = [UIImage imageNamed:@"listicon_clipboard.png"];
    }
    return image;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredListContent count];
    }
	else
	{
        return [history count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    UIView *background =[[UIView alloc] initWithFrame:cell.frame];
    background.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = background;
    
    NSDictionary *data = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        data = [filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        data = [history objectAtIndex:indexPath.row];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyy/MM/dd HH:mm";
    NSDate *date = [data objectForKey:@"date"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [data objectForKey:@"category"];
    [label sizeToFit];
    UILabel *detail = (UILabel *)[cell viewWithTag:2];
    detail.frame = CGRectMake((int)(label.frame.origin.x + label.frame.size.width + 5), label.frame.origin.y + 3, 0, 43);
    if ([[data objectForKey:@"type"] isEqualToString:@"decode"])
    {
        detail.text = [NSString stringWithFormat:@"— 読取済み %@", [self calculateIntervalSinceNow:date]];
    }
    else
    {
        detail.text = [NSString stringWithFormat:@"— 作成済み %@", [self calculateIntervalSinceNow:date]];
    }
    [detail sizeToFit];
    UILabel *content = (UILabel *)[cell viewWithTag:3];
    content.text = [data objectForKey:@"text"];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:4];
    imageView.image = [self listIconFromLabel:[data objectForKey:@"category"]];
    
    return cell;
}

- (NSString *)calculateIntervalSinceNow:(NSDate *)date
{
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    
    if ((int)-timeInterval/(3600 * 24) > 0)
    {
        return [NSString stringWithFormat:@"%d 日前", (int)-timeInterval/(3600 * 24)];
    }
    else if ((int)-timeInterval/3600 > 0)
    {
        return [NSString stringWithFormat:@"%d 時間前", (int)-timeInterval/3600];
    }
    else if ((int)-timeInterval/60 > 0)
    {
        return [NSString stringWithFormat:@"%d 分前", (int)-timeInterval/60];
    }
    else
    {
        return [NSString stringWithFormat:@"%d 秒前", (int)-timeInterval];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [history removeObjectAtIndex:indexPath.row];
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setValue:[history copy] forKey:@"HISTORY"];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) detailDiscolosureIndicatorSelected:(UIButton *)sender
{
    if ([[[history objectAtIndex:[self.tableView indexPathForSelectedRow].row] objectForKey:@"type"] isEqualToString:@"decode"])
    {
        [GramContext get]->decodeFromHistory = [history objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [self performSegueWithIdentifier:@"detailSegue" sender:self];
    }
    else
    {
        [GramContext get]->encodeFromHistory = [history objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [self performSegueWithIdentifier:@"generateSegue" sender:self];
    }
}

- (void)resetUI
{
    // leave edit mode for our table and apply the edit button
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.tableView setEditing:NO animated:YES];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.isEditing)
    {
        NSDictionary *data = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            data = [filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            data = [history objectAtIndex:indexPath.row];
        }
        
        if ([[data objectForKey:@"type"] isEqualToString:@"decode"])
        {
            [GramContext get]->decodeFromHistory = data;
            [self performSegueWithIdentifier:@"detailSegue" sender:self];
        }
        else
        {
            [GramContext get]->encodeFromHistory = data;
            [self performSegueWithIdentifier:@"generateSegue" sender:self];
        }
    }
}

- (IBAction)tapChangeMode:(id)sender
{
    [self performSegueWithIdentifier:@"changeSegue" sender:self];
}

- (void)tapDelete:(id)sender
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (selectedRows.count > 0)
    {
        // setup our deletion array so they can all be removed at once
        NSMutableArray *deletionArray = [NSMutableArray array];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [deletionArray addObject:[history objectAtIndex:selectionIndex.row]];
        }
        [history removeObjectsInArray:deletionArray];
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setValue:[history copy] forKey:@"HISTORY"];
        [settings synchronize];
        
        // then delete the only the rows in our table that were selected
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *current = @"history";
    
    if ([segue.identifier isEqualToString:@"detailSegue"])
    {
        NSLog(@"tether: %@ detailSegue", current);
        
        DetailViewController *view = segue.destinationViewController;
        view.phase = current;
    }
    else if ([segue.identifier isEqualToString:@"generateSegue"])
    {
        NSLog(@"tether: %@ generateSegue", current);
        
        BarCodeViewController *view = segue.destinationViewController;
        view.phase = current;
    }
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *data in history)
	{
			NSComparisonResult result = [[data objectForKey:@"text"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[filteredListContent addObject:data];
            }
	}
    
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)resultTableView
{
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.bannerIsVisible)
    {
        resultTableView.frame = CGRectMake(frame.origin.x,
                                     frame.origin.y + 44,
                                     frame.size.width,
                                     frame.size.height - 93 - 49);
    }
    else
    {
        resultTableView.frame = CGRectMake(frame.origin.x,
                                     frame.origin.y + 44,
                                     frame.size.width,
                                     frame.size.height - 93);
    }
    
    NSLog(@"%f", self.searchDisplayController.searchResultsTableView.frame.size.height);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

#pragma mark - custom delegete

- (void)bannerIsInvisible
{
    NSLog(@"delegate bannerIsInvisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.tableView setFrame:CGRectMake(frame.origin.x,
                                        frame.origin.y,
                                        frame.size.width,
                                        frame.size.height - 93)];
    [self.searchDisplayController.searchResultsTableView setFrame:CGRectMake(frame.origin.x,
                                                                             frame.origin.y + 44,
                                                                             frame.size.width,
                                                                             frame.size.height - 93)];
    [UIView commitAnimations];
}

- (void)bannerIsVisible
{
    NSLog(@"delegate bannerIsVisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.tableView setFrame:CGRectMake(frame.origin.x,
                                        frame.origin.y,
                                        frame.size.width,
                                        frame.size.height - 93 - 49)];
    [self.searchDisplayController.searchResultsTableView setFrame:CGRectMake(frame.origin.x,
                                                                             frame.origin.y + 44,
                                                                             frame.size.width,
                                                                             frame.size.height - 93 -  49)];
    [UIView commitAnimations];
}

@end
