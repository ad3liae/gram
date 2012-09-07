//
//  UITabBarWithAdController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/06.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "UITabBarWithAdDelegate.h"

@interface UITabBarWithAdController : UITabBarController <ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    
    id<UITabBarWithAdDelegate> delegate;
}

@property (nonatomic, retain) ADBannerView *adView;
@property (nonatomic, assign) BOOL bannerIsVisible;
@property (nonatomic, retain) id delegate;

@end
