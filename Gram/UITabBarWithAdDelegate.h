//
//  UITabBarWithAdDelegate.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/07.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UITabBarWithAdDelegate <NSObject>

@optional
- (void)bannerIsVisible;
- (void)bannerIsInvisible;

@end