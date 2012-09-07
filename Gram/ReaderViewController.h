//
//  ReaderViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/27.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UITabBarWithAdDelegate.h"
#import "CaptureViewDelegate.h"

@interface ReaderViewController : UIViewController <NSURLConnectionDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate, CaptureViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *phase;
- (IBAction)tapAction:(id)sender;
- (IBAction)tapCamera:(id)sender;

@end
