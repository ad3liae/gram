//
//  SettingsViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarWithAdDelegate.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
