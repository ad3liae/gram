//
//  SettingsDetailViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "SettingsDetailViewController.h"
#import "GramContext.h"
#import "UITabBarWithAdController.h"

@interface SettingsDetailViewController ()
{
    NSString *condition;
    NSArray *labels;
    NSIndexPath *lastIndexPath;
    CGRect frame;
}

@end

@implementation SettingsDetailViewController
@synthesize phase = _phase;
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
    if ([_phase isEqualToString:@"reader"])
    {
        condition = [GramContext get]->importMode;
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"自動判別", @"連絡先", @"イベント", nil], [NSArray arrayWithObjects:@"URL", @"名前", @"電話番号", @"Eメール", @"ツイッター", @"フェイスブック", nil], nil];
    }
    else if ([_phase isEqualToString:@"settings"])
    {
        condition = [GramContext get]->condition;
        
        if ([condition isEqualToString:@"バージョン情報"])
        {
            labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"バージョン", nil], nil];
        }
        else if ([condition isEqualToString:@"誤り訂正レベル"])
        {
            labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"L", @"M", @"Q", @"H", nil], nil];
        }
    }
    
    self.title = condition;
    
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    tabBar.delegate = self;
    
    [UIView beginAnimations:@"ad" context:nil];
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
    [UIView commitAnimations];
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
}

#pragma mark - Custom methods

- (NSString *)getConditionFromLabel:(NSString *)label
{
    NSString *value = nil;
    if ([label isEqualToString:@"バージョン"])
    {
        value = [NSString stringWithFormat:@"%@ (%@)",
         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
         [NSString stringWithFormat:@"%x",
          [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]]];
    }
    return value;
}

- (void)setConditionFromLabel:(NSString *)label
{
    if ([condition isEqualToString:@"誤り訂正レベル"])
    {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:label forKey:@"QR_ERROR_CORRECTION_LEVEL"];
        [settings synchronize];
    }
    else if ([condition isEqualToString:@"インポート形式"])
    {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:label forKey:@"IMPORT_MODE"];
        [settings synchronize];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    
    if ([condition isEqualToString:@"誤り訂正レベル"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        if ([[[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString:[settings objectForKey:@"QR_ERROR_CORRECTION_LEVEL"]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastIndexPath = indexPath;
        }
    }
    else if ([condition isEqualToString:@"インポート形式"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        if ([[[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString:[settings objectForKey:@"IMPORT_MODE"]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastIndexPath = indexPath;
        }
    }
    
    cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self getConditionFromLabel:cell.textLabel.text];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([condition isEqualToString:@"誤り訂正レベル"] || [condition isEqualToString:@"インポート形式"])
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
