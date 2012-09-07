//
//  GenerateViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UITabBarWithAdDelegate.h"

@interface GenerateViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarWithAdDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
