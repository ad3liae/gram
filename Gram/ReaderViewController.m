//
//  ReaderViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/27.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ReaderViewController.h"
#import "CaptureViewController.h"
#import "DetailViewController.h"
#import "SettingsDetailViewController.h"
#import "UITabBarWithAdController.h"
#import "GramContext.h"
#import "HTMLParser.h"

@interface ReaderViewController ()
{
    UIBarButtonItem *item;
    NSArray *labels;
    UIView *mask;
    NSMutableData *receivedData;
    NSString *url;
    BOOL completed;
    BOOL redirected;
    NSInteger statusCode;
    NSString *advice;
    NSIndexPath *lastIndexPath;
    CaptureViewController *capture;
    CGRect frame;
}

@end

@implementation ReaderViewController
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
    
    item = self.navigationItem.rightBarButtonItem;
    
    [GramContext get]->captured = nil;
    [GramContext get]->bootCompleted = YES;
    
    _phase = @"reader";
    self.navigationItem.title = @"読取";
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings boolForKey:@"INSTANT_BOOT_MODE"] != NO)
    {
        [GramContext get]->bootCompleted = NO;
        self.navigationController.navigationBar.hidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        self.tableView.backgroundColor = [UIColor blackColor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.tableView viewWithTag:1] != nil)
        [[self.tableView viewWithTag:1] removeFromSuperview];
    
    labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"カメラロールから作成する", nil], nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 10, 269, 259)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = 1;
    imageView.image = [UIImage imageNamed:@"reticle.png"];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 236, 269, 40)];
    notice.numberOfLines = 0;
    notice.text = @"枠の中に収まるように\nバーコードをセットしてください";
    notice.textAlignment = UITextAlignmentCenter;
    notice.font = [UIFont systemFontOfSize:15.0];
    notice.shadowOffset = CGSizeMake(0, -1);
    notice.shadowColor = [UIColor darkGrayColor];
    notice.backgroundColor = [UIColor clearColor];
    notice.textColor = [UIColor whiteColor];
    [imageView addSubview:notice];
    [self.tableView addSubview:imageView];
    
    if (lastIndexPath != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
        
        lastIndexPath = nil;
    }
    else
    {
        [self.tableView reloadData];
    }
    
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
    if (self.tabBarController.delegate == self)
    {
        self.tabBarController.delegate = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.tabBarController.tabBar.hidden != NO)
    {
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    advice = nil;
    
    if ([GramContext get]->bootCompleted != YES)
    {
        [GramContext get]->bootCompleted = YES;
        [self performSegueWithIdentifier:@"instantSegue" sender:self];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 300;
    }
    
    return tableView.sectionHeaderHeight;
}
/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"selectableCell"];
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastIndexPath = indexPath;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)tapCamera:(id)sender
{
    [self performSegueWithIdentifier:@"captureSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *current = [NSString stringWithFormat:@"%@->detail", _phase];
    
    if ([segue.identifier isEqualToString:@"importSegue"])
    {
        NSLog(@"tether: %@ importSegue", current);
        
        DetailViewController *view = segue.destinationViewController;
        view.phase = current;
    }
    else if ([segue.identifier isEqualToString:@"captureSegue"])
    {
        NSLog(@"tether: %@ captureSegue", current);
        
        CaptureViewController *view = segue.destinationViewController;
        capture = view;
        capture.delegate = self;
    }
        
}

-(BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 0)
    {
        [self performSegueWithIdentifier:@"captureSegue" sender:self];
        return NO;
    }
    
    return YES;
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

- (void)dismissCameraView
{
    if (capture != nil)
    {
        capture.delegate = nil;
        capture = nil;
        self.tabBarController.delegate = nil;
        [self performSegueWithIdentifier:@"importSegue" sender:self];
    }
}

@end
