//
//  HistoryListViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "UITabBarWithAdDelegate.h"

@interface HistoryListViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate, UITabBarWithAdDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)tapChangeMode:(id)sender;

@end
