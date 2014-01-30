//
//  ExportDetailViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ExportDetailViewController.h"

#import "UITabBarWithAdController.h"

@interface ExportDetailViewController ()
{
    NSString *condition;
    NSArray *labels;
    NSIndexPath *lastIndexPath;
    CGRect frame;
}

@end

@implementation ExportDetailViewController
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
    if (lastIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    }
    
    condition = [GramContext get]->exportDetailCondition;
    if ([condition isEqualToString:@"セキュリティ"])
    {
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"WEP", @"WPA/WPA2", @"なし", nil], nil];
    }
    
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

#pragma mark - Custom methods

- (void)setConditionFromLabel:(NSString *)label
{
    if ([condition isEqualToString:@"セキュリティ"])
    {
        [GramContext get]->securityType = label;
    }
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
    
    if ([condition isEqualToString:@"セキュリティ"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        if ([[[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString:[GramContext get]->securityType])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastIndexPath = indexPath;
        }
    }
    
    cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([condition isEqualToString:@"セキュリティ"])
    {
        NSInteger previousRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
        NSInteger previousSection = (lastIndexPath != nil) ? [lastIndexPath section] : -1;
        if ([indexPath row] != previousRow || [indexPath section] != previousSection)
        {
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:lastIndexPath];
            previousCell.accessoryType = UITableViewCellAccessoryNone;
            [self setConditionFromLabel:[[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            lastIndexPath = indexPath;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
