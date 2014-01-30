//
//  GenerateViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "GenerateViewController.h"

#import "Kal.h"
#import "EventKitDataSource.h"
#import "UITabBarWithAdController.h"

@interface NSString (NSString_Extended)
- (NSString *)urlencode;
- (NSString *)matchWithPattern:(NSString *)pattern;
- (NSString *)matchWithPattern:(NSString *)pattern options:(NSInteger)options;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace options:(NSInteger)options;
@end

@interface GenerateViewController ()
{
    NSArray *labels;
    NSMutableArray *contactList;
    ABAddressBookRef addressBook;
    BOOL foundSearchBar;
    ABPeoplePickerNavigationController *picker;
    KalViewController *kal;
    UINavigationController *kalView;
    id dataSource;
    NSString *vCard;
    NSString *vEvent;
    NSIndexPath *lastIndexPath;
    CGRect frame;
    NSMutableArray *record;
    CFArrayRef personRecordRef;
}

@end

@implementation GenerateViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    frame = [self.tableView frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    labels = [NSArray arrayWithObjects:
              [NSArray arrayWithObjects:@"URL", @"場所", @"連絡先", @"イベント", nil],
              [NSArray arrayWithObjects:@"電話番号", @"SMS", @"Eメール", @"ツイッター", @"フェイスブック", nil],
              [NSArray arrayWithObjects:@"Wi-Fiネットワーク", nil], //@"Foursquareの登録スポット", 
              [NSArray arrayWithObjects:@"テキスト", @"クリップボードの内容", nil], nil];
    
    self.navigationItem.title = @"コード作成";
}

- (void)viewWillAppear:(BOOL)animated
{
    if (lastIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    }
    
    vCard = nil;
    vEvent = nil;
    
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    tabBar.delegate = self;
    
    if (tabBar.bannerIsVisible)
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93 -  49)];
    }
    else
    {
        [self.tableView setFrame:CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            frame.size.height - 93)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.delegate == self)
    {
        tabBar.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *)listIconFromLabel:(NSString *)label
{
    UIImage *image = nil;
    if ([label isEqualToString:@"URL"])
    {
        image = [UIImage imageNamed:@"listicon_url.png"];
    }
    else if ([label isEqualToString:@"場所"])
    {
        image = [UIImage imageNamed:@"listicon_map.png"];
    }
    else if ([label isEqualToString:@"連絡先"])
    {
        image = [UIImage imageNamed:@"listicon_address.png"];
    }
    else if ([label isEqualToString:@"イベント"])
    {
        image = [UIImage imageNamed:@"listicon_event.png"];
    }
    else if ([label isEqualToString:@"電話番号"])
    {
        image = [UIImage imageNamed:@"listicon_tel.png"];
    }
    else if ([label isEqualToString:@"SMS"])
    {
        image = [UIImage imageNamed:@"listicon_sms.png"];
    }
    else if ([label isEqualToString:@"Eメール"])
    {
        image = [UIImage imageNamed:@"listicon_email.png"];
    }
    else if ([label isEqualToString:@"ツイッター"])
    {
        image = [UIImage imageNamed:@"listicon_twitter.png"];
    }
    else if ([label isEqualToString:@"フェイスブック"])
    {
        image = [UIImage imageNamed:@"listicon_facebook.png"];
    }
    else if ([label isEqualToString:@"Wi-Fiネットワーク"])
    {
        image = [UIImage imageNamed:@"listicon_wifi.png"];
    }
    else if ([label isEqualToString:@"テキスト"])
    {
        image = [UIImage imageNamed:@"listicon_text.png"];
    }
    else if ([label isEqualToString:@"クリップボードの内容"])
    {
        image = [UIImage imageNamed:@"listicon_clipboard.png"];
    }
    return image;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [labels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[labels objectAtIndex:section] count];
}
/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (kal != nil)
    {
        return 0;
    }
    
    return tableView.;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"exportCell"];
    NSString *label = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    textLabel.text = label;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
    imageView.image = [self listIconFromLabel:label];
    
    return cell;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (lastIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef *multi = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multi, identifier);
    NSString *data = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multi, index);
    NSDictionary *selectedField = @{@"key":[NSString stringWithFormat:@"%d", property], @"value":data};
    
    UIView *view = peoplePicker.topViewController.view;
    UITableView *tableView = nil;
    
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[UITableView class]])
        {
            tableView = (UITableView *)v;
            break;
        }
    }
    
    if (tableView != nil)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [record addObject:selectedField];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSInteger index = 0;
            for (NSDictionary *field in record)
            {
                if ([[field objectForKey:@"key"] isEqualToString:[NSString stringWithFormat:@"%d", property]] &&
                    [[field objectForKey:@"value"] isEqualToString:data])
                {
                    break;
                }
                else
                {
                    index++;
                }
            }
            [record removeObjectAtIndex:index];
        }
        
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    picker = peoplePicker;
    NSArray *array = [NSArray arrayWithObject:(__bridge id)(person)];
    /*
    int i;
    for (i = 0; i < [array count]; i++) {
        // Get the actual person
        ABRecordRef record = (__bridge ABRecordRef)([array objectAtIndex:i]);
        bool gotAddress = NO;
        
        // Get the address properties.
        ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);
        
        for(CFIndex j=0;j<ABMultiValueGetCount(multiValue);j++)
        {
            CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, j);
            CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
            CFStringRef zip = CFDictionaryGetValue(dict, kABPersonAddressZIPKey);
            CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
            CFRelease(dict);
            
            if(street != nil || zip != nil || city != nil)
                gotAddress = YES;
        }
        
        if(gotAddress)
        {
            NSLog(@"%d", gotAddress);
            //[filteredPeopleWithAddress addObject:record];
        }
    }
    */
    
    
    CFArrayRef arrayRef = (__bridge CFArrayRef)array;
    
    NSData *vCards = (__bridge NSData *)ABPersonCreateVCardRepresentationWithPeople(arrayRef);
    vCard = [[NSString alloc] initWithData:(NSData *)vCards encoding:NSUTF8StringEncoding];
    
    record = [NSMutableArray array];
    
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]])
    {
        if ([viewController isKindOfClass:[ABPersonViewController class]])
        {
            navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(tapExportContact:)];
        }
        else
        {
            navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tapCancel:)];
        }
    }
    else
    {
        if ([viewController isKindOfClass:[EKEventViewController class]])
        {
            navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(tapExportEvent:)];
        }
        else
        {
            navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tapCancel:)];
        }
    }
}

- (void)tapExportContact:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"エクスポート"
                                  delegate:self
                                  cancelButtonTitle:@"キャンセル"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"すべての項目",
                                  @"選択した項目のみ", nil];
    [actionSheet showInView:picker.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [GramContext get]->encodeString = vCard;
        NSLog(@"%@", vCard);
        [self performSegueWithIdentifier:@"createSegue" sender:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapExportEvent:(id)sender
{
    if (vEvent != nil)
    {
        kal = nil;
        [GramContext get]->encodeString = vEvent;
        NSLog(@"%@", vEvent);
        [self performSegueWithIdentifier:@"createSegue" sender:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapCancel:(id)sender
{
    kal = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (lastIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    }
}

- (void)showAndSelectToday
{
    [kal showAndSelectDate:[NSDate date]];
}

- (void)findSearchBar:(UIView *)parent mark:(NSString *)mark
{
    for(UIView *v in [parent subviews])
    {
        if(foundSearchBar)
            return;
        
        NSLog(@"%@%@", mark, NSStringFromClass([v class]));
        
        if([v isKindOfClass:[UISearchBar class]])
        {
            [(UISearchBar *)v setTintColor:[UIColor blackColor]];
            foundSearchBar = YES;
            break;
        }
        [self findSearchBar:v mark:[mark stringByAppendingString:@"> "]];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kal != nil)
    {
        //CGICalendarProperty *prop;
        EKEventViewController *vc = [[EKEventViewController alloc] init];
        vc.event = [dataSource eventAtIndexPath:indexPath];
        vc.allowsEditing = NO;
        kalView.delegate = self;
        vEvent = @"sample";
        /*
        CGICalendar *cal = [CGICalendar new];
        CGICalendarObject *obj = [CGICalendarObject objectWithProdid:@"//CyberGarage//iCal4ObjC//EN"];
        CGICalendarComponent *component = [CGICalendarComponent componentWithType:@"VEVENT"];
        
        prop = [CGICalendarProperty new];
        prop.name = @"SUMMARY";
        prop.value = vc.event.title;
        [component addProperty:prop];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        prop = [CGICalendarProperty new];
        prop.name = @"DTSTART";
        prop.value = [formatter stringFromDate:vc.event.startDate];
        [component addProperty:prop];
        
        prop = [CGICalendarProperty new];
        prop.name = @"DTEND";
        prop.value = [formatter stringFromDate:vc.event.endDate];
        [component addProperty:prop];
        [obj addComponent:component];
        [cal addObject:obj];
        
        NSString *output = [cal write];
        NSLog(@"iCalendar format: %@", output);
        vEvent = output;
        */
        [kalView pushViewController:vc animated:YES];
    }
    else
    {
        lastIndexPath = indexPath;
        NSString *label = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([label isEqualToString:@"連絡先"])
        {
            [GramContext get]->exportCondition = label;
            ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.peoplePickerDelegate = self;
            picker.topViewController.navigationController.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            
            /*
            NSString *card = @"";
            ABRecordRef person;
            @try {
                person = ABPersonCreate();
                ABPersonCreatePeopleInSourceWithVCardRepresentation(person, (__bridge CFDataRef)[card dataUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%@", person);
            } @finally {
                CFRelease(person);
            }
            */
            //foundSearchBar = NO;
            //[self findSearchBar:[picker view] mark:@"> "];
            //picker.navigationBar.tintColor = [UIColor blackColor];
        }
        if ([label isEqualToString:@"イベント"])
        {
            [GramContext get]->exportCondition = label;
            kal = [[KalViewController alloc] init];
            kal.delegate = self;
            dataSource = [[EventKitDataSource alloc] init];
            kal.dataSource = dataSource;
            kalView = [[UINavigationController alloc] initWithRootViewController:kal];
            kal.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                                     UIBarButtonSystemItemCancel target:self action:@selector(tapCancel:)];
            kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)];
            [self presentViewController:kalView animated:YES completion:nil];
            /*EKEventStore *eventStore = [[EKEventStore alloc] init];
             [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
             if (granted)
             {
             NSLog(@"Access to Event Store Granted");
             
             //[self eventPicker];
             }
             else
             {
             NSLog(@"Access to Event Store not Granted");
             }
             }];
             
             switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
             case EKAuthorizationStatusAuthorized:
             // ok, access is granted nothing to do here.
             [self eventPicker];
             break;
             case EKAuthorizationStatusDenied:
             av = [[UIAlertView alloc] initWithTitle:@"Access denied"
             message:@"Calendar access is denied. If you want to use feature xy you need to grant calendar access..."
             delegate:self
             cancelButtonTitle:@"Dismiss"
             otherButtonTitles:nil];
             [av show];
             return;
             break;
             case EKAuthorizationStatusNotDetermined:
             // Ok, we've never asked, so let's do it now.
             [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^ (BOOL granted, NSError *error) {
             if (!granted)
             {
             // ...
             }
             }];
             return;
             break;
             case EKAuthorizationStatusRestricted:
             return;
             break;
             default:
             break;
             }
             */
            //[self performSegueWithIdentifier:@"listSegue" sender:self];
        }
        else if ([label isEqualToString:@"電話番号"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"SMS"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"Eメール"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"URL"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"場所"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"Wi-Fiネットワーク"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"テキスト"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"クリップボードの内容"])
        {
            [GramContext get]->exportCondition = label;
            [self performSegueWithIdentifier:@"exportSegue" sender:self];
        }
        else if ([label isEqualToString:@"ツイッター"] || [label isEqualToString:@"フェイスブック"] || [label isEqualToString:@"Foursquareの登録スポット"])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark - custom delegete

- (void)bannerIsInvisible
{
    NSLog(@"delegate bannerIsInvisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.tableView setFrame:CGRectMake(frame.origin.x,
                                        frame.origin.y,
                                        frame.size.width,
                                        frame.size.height - 93)];
    [UIView commitAnimations];
}

- (void)bannerIsVisible
{
    NSLog(@"delegate bannerIsVisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.tableView setFrame:CGRectMake(frame.origin.x,
                                        frame.origin.y,
                                        frame.size.width,
                                        frame.size.height - 93 - 49)];
    [UIView commitAnimations];
}

@end
