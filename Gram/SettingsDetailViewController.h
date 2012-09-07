//
//  SettingsDetailViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarWithAdDelegate.h"

@interface SettingsDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate>
@property (nonatomic, retain) NSString *phase;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
