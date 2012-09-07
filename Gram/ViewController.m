//
//  ViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/27.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self callContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)callContent
{
    [self performSegueWithIdentifier:@"contentSegue" sender:self];
}

@end
