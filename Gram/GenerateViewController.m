//
//  GenerateViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "GenerateViewController.h"
#import "GramContext.h"
#import "Kal.h"
#import "EventKitDataSource.h"
#import "UITabBarWithAdController.h"

@interface GenerateViewController ()
{
    NSArray *labels;
    NSMutableArray *contactList;
    ABAddressBookRef addressBook;
    BOOL foundSearchBar;
    KalViewController *kal;
    UINavigationController *kalView;
    id dataSource;
    NSString *vCard;
    NSString *vEvent;
    NSIndexPath *lastIndexPath;
    CGRect frame;
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
    //[self dismissModalViewControllerAnimated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    NSArray *array = [NSArray arrayWithObject:(__bridge id)(person)];
    CFArrayRef arrayRef = (__bridge CFArrayRef)array;
    NSData *vCards = (__bridge NSData *)ABPersonCreateVCardRepresentationWithPeople(arrayRef);
    vCard = [[NSString alloc] initWithData:(NSData *)vCards encoding:NSUTF8StringEncoding];
    
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
    if (vCard != nil)
    {
        [GramContext get]->encodeString = vCard;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"createSegue" sender:self];
    }
}

- (void)tapExportEvent:(id)sender
{
    if (vEvent != nil)
    {
        [GramContext get]->encodeString = vEvent;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"createSegue" sender:self];
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
            
            NSString *card =
            @"BEGIN:VCARD"
            "VERSION:2.1"
            "N:Yoshimura;Takahiro;;;"
            "FN:Takahiro Yoshimura"
            "TEL;CELL:090-833-25633"
            "TEL;WORK:050-583-72095"
            "EMAIL:altakey@gmail.com"
            "EMAIL;WORK:takahiro_y@monolithworks.co.jp"
            "EMAIL:alterakey@docomo.ne.jp"
            "ADR;HOME;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;;=E7=93=A6=E8=91=BA=31=33=32=34=2D=31=2D=31=30=31=0A=E4=B8=8A=E5=B0=BE="
            "=E5=B8=82=2C=20=E5=9F=BC=E7=8E=89=E7=9C=8C=20=33=36=32=2D=30=30=32=32="
            "=0A=E6=97=A5=E6=9C=AC;;;;"
            "ORG;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE=E3=83=A2=E3=83=8E=E3=83=AA=E3=82="
            "=B9=E3=83=AF=E3=83=BC=E3=82=AF=E3=82=B9"
            "PHOTO;ENCODING=BASE64;JPEG:/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwM"
            " EAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/"
            " 2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUF"
            " BQUFBQUFBQUFBQUFBT/wAARCABgAGADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAA"
            " ECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaE"
            " II0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZn"
            " aGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJy"
            " tLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAw"
            " QFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobH"
            " BCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hp"
            " anN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0"
            " tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDsPDf7QWs/ELw/4skudJ"
            " sk1/TrEal/aFpI0KTg3UETq0IBBdvOI3ArkE5B7/RXxW/aGudF+F+vaxYRy2KHWk0q2kGCYEF"
            " pFM/TuT5gHoDnjFfMngD4b2/gTw58RZv7Rn1jUItINpcSWenSjTbdxfWrGI3MgXfL8oO1U24y"
            " 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"
            ""
            "END:VCARD"
            "";
            
            ABRecordRef person;
            @try {
                person = ABPersonCreate();
                ABPersonCreatePeopleInSourceWithVCardRepresentation(person, (__bridge CFDataRef)[card dataUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%@", person);
            } @finally {
                CFRelease(person);
            }
            
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
