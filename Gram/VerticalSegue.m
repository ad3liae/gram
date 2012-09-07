//
//  VerticalSegue.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "VerticalSegue.h"

@implementation VerticalSegue

- (void)perform
{
    UIViewController *sourceViewController = (UIViewController *)self.sourceViewController;
    UIViewController *destinationViewController = (UIViewController *)self.destinationViewController;
    [UIView transitionWithView:sourceViewController.navigationController.view
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        [sourceViewController.navigationController pushViewController:destinationViewController animated:NO];
                    }
                    completion:nil];
}

@end
