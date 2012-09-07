//
//  UITabBarWithAdController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/06.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "UITabBarWithAdController.h"

@interface UITabBarWithAdController ()

@end

@implementation UITabBarWithAdController
@synthesize adView;
@synthesize bannerIsVisible;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, -320, 381);
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self.view insertSubview:adView atIndex:1];
    adView.delegate = self;
    self.bannerIsVisible = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"loaded");
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 320, 0);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
        
        NSLog(@"%@", delegate);
        if (delegate != nil)
        {
            [delegate bannerIsVisible];
        }
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"failed");
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, -320, 0);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
        
        if (delegate != nil)
        {
            [delegate bannerIsInvisible];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    adView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    adView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
