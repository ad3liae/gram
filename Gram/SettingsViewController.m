//
//  SettingsViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsDetailViewController.h"
#import "GramContext.h"
#import "UITabBarWithAdController.h"

@interface SettingsViewController ()
{
    NSArray *labels;
    CGRect frame;
}

@end

@implementation SettingsViewController
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
    
    labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"バージョン情報", nil], [NSArray arrayWithObjects:@"起動後すぐに読取を開始", @"自動遷移モード", @"連続読取モード", @"誤り訂正レベル", @"位置情報の付加", nil],nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    tabBar.delegate = self;
    [self.tableView reloadData];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectableCell" forIndexPath:indexPath];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    NSString *label = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 1)
    {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        if ([label isEqualToString:@"誤り訂正レベル"])
        {
            cell.detailTextLabel.text = [settings objectForKey:@"QR_ERROR_CORRECTION_LEVEL"];
        }
        else
        {
            UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 90, 24.0)];
            cell.accessoryView = uiSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([label isEqualToString:@"自動遷移モード"])
            {
                [uiSwitch setOn:[settings boolForKey:@"AUTOMATIC_MODE"]];
                [(UISwitch *)cell.accessoryView addTarget:self action:@selector(switch2Changed:)
                                         forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
            }
            else if ([label isEqualToString:@"連続読取モード"])
            {
                [uiSwitch setOn:[settings boolForKey:@"CONTINUOUS_MODE"]];
                [(UISwitch *)cell.accessoryView addTarget:self action:@selector(switch0Changed:)
                                         forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
            }
            else if ([label isEqualToString:@"位置情報の付加"])
            {
                [uiSwitch setOn:[settings boolForKey:@"USE_LOCATION"]];
                [(UISwitch *)cell.accessoryView addTarget:self action:@selector(switch1Changed:)
                                         forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
            }
            else if ([label isEqualToString:@"起動後すぐに読取を開始"])
            {
                [uiSwitch setOn:[settings boolForKey:@"INSTANT_BOOT_MODE"]];
                [(UISwitch *)cell.accessoryView addTarget:self action:@selector(switch3Changed:)
                                         forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
            }
        }
    }
    cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)switch0Changed:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:[(UISwitch *)sender isOn] forKey:@"CONTINUOUS_MODE"];
    [settings synchronize];
}

- (void)switch1Changed:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:[(UISwitch *)sender isOn] forKey:@"USE_LOCATION"];
    [settings synchronize];
}

- (void)switch2Changed:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:[(UISwitch *)sender isOn] forKey:@"AUTOMATIC_MODE"];
    [settings synchronize];
}

- (void)switch3Changed:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:[(UISwitch *)sender isOn] forKey:@"INSTANT_BOOT_MODE"];
    [settings synchronize];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *label = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([label isEqualToString:@"バージョン情報"] || [label isEqualToString:@"誤り訂正レベル"])
    {
        [GramContext get]->condition = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"detailSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *current = @"settings";
    
    if ([segue.identifier isEqualToString:@"detailSegue"])
    {
        NSLog(@"tether: %@ detailSegue", current);
        
        SettingsDetailViewController *view = segue.destinationViewController;
        view.phase = current;
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
