//
//  ExportTypeViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/06.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ExportTypeViewController.h"

#import "UITabBarWithAdController.h"

@interface ExportTypeViewController ()
{
    NSString *condition;
    NSIndexPath *lastIndexPath;
    CGRect frame;
}

@end

@implementation ExportTypeViewController
@synthesize phase = _phase;
@synthesize labels;
@synthesize label;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    condition = @"エクスポート形式";
    self.title = condition;
    
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    tabBar.delegate = self;
    
    if (tabBar.bannerIsVisible)
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93 -  49)];
    }
    else
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93)];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [labels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[labels objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    
    if ([[[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString:label])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        lastIndexPath = indexPath;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger previousRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    NSInteger previousSection = (lastIndexPath != nil) ? [lastIndexPath section] : -1;
    if ([indexPath row] != previousRow || [indexPath section] != previousSection)
    {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([_phase isEqualToString:@"history->detail"])
        {
            [GramContext get]->exportModeFromHistory = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        else
        {
            [GramContext get]->exportMode = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        
        lastIndexPath = indexPath;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [UIView commitAnimations];
}

@end
