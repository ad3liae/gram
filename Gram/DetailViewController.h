//
//  DetailViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/05.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarWithAdDelegate.h"

@interface DetailViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate>
@property (nonatomic, retain) NSString *phase;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)tapAction:(id)sender;

@end
