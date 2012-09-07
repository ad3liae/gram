//
//  ExportTypeViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/06.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarWithAdDelegate.h"

@interface ExportTypeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate>
@property (nonatomic, retain) NSString *phase;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSString *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
