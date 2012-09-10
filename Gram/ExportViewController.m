//
//  ExportViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ExportViewController.h"
#import "BarCodeViewController.h"
#import "GramContext.h"
#import "UITabBarWithAdController.h"

@interface ExportViewController ()
{
    NSString *condition;
    NSArray *labels;
    UITextField *ssid;
    UITextField *password;
    UILabel *security;
    UITextField *tel;
    UITextField *mailAddress;
    UITextField *url;
    UITextField *subject;
    UITextView *inputTextArea;
    UILabel *placeHolder;
    NSIndexPath *lastIndexPath;
    CGRect frame;
}

@end

@implementation ExportViewController
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
    
    [GramContext get]->securityType = @"WPA/WPA2";
    [GramContext get]->locationFromMap = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (lastIndexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
    }
    
    condition = [GramContext get]->exportCondition;
    if ([condition isEqualToString:@"電話番号"])
    {
        self.title = @"電話番号";
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"電話番号", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"SMS"])
    {
        self.title = @"SMS";
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"電話番号", nil],
                  [NSArray arrayWithObjects:@"メッセージを入力", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"Eメール"])
    {
        self.title = @"Eメール";
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"宛先", @"件名", nil],
                  [NSArray arrayWithObjects:@"本文を入力", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"URL"])
    {
        self.title = @"URL";
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"URL", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"場所"])
    {
        self.title = @"場所";
        if (lastIndexPath)
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
            CLLocation *locationFromMap = [GramContext get]->locationFromMap;
            if (locationFromMap != nil)
            {
                CLLocationCoordinate2D coordinate = locationFromMap.coordinate;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
            }
            else
            {
                cell.detailTextLabel.text = @"現在地";
            }
        }
        
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"場所", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"Wi-Fiネットワーク"])
    {
        self.title = @"Wi-Fiネットワーク";
        labels = [NSArray arrayWithObjects:
                  [NSArray arrayWithObjects:@"SSID", @"パスワード", @"セキュリティ", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"URL"])
    {
        labels = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"L", @"M", @"Q", @"H", nil], nil];
    }
    else if ([condition isEqualToString:@"テキスト"])
    {
        self.title = @"テキスト";
        labels = [NSArray arrayWithObjects:
                  [NSArray arrayWithObjects:@"テキストを入力", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    else if ([condition isEqualToString:@"クリップボードの内容"])
    {
        self.title = @"クリップボード";
        labels = [NSArray arrayWithObjects:
                  [NSArray arrayWithObjects:@"テキストを入力", nil],
                  [NSArray arrayWithObjects:@"作成する", nil], nil];
    }
    
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
    if (inputTextArea != nil)
    {
        [inputTextArea resignFirstResponder];
    }
    
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.delegate == self)
    {
        tabBar.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - labels/label method

- (NSString *)labelAtIndexPath:(NSIndexPath *)indexPath
{
    return [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - TextField/TextView delegete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([text isEqualToString:@"\n"])
    {
        [inputTextArea resignFirstResponder];
        return NO;
    }
    else
    {
        if (newString.length > 0)
        {
            placeHolder.alpha = 0;
        }
        else
        {
            placeHolder.alpha = 1;
        }
    }
    return YES;
}

#pragma mark - System Configuration

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    //NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs)
    {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count])
        {
            break;
        }
    }
    
    return info;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *label = [self labelAtIndexPath:indexPath];
    if ([label isEqualToString:@"テキストを入力"] || [label isEqualToString:@"メッセージを入力"] || [label isEqualToString:@"本文を入力"])
    {
        return 170;
    }
    
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([condition isEqualToString:@"Wi-Fiネットワーク"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"テキスト"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"クリップボードの内容"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"電話番号"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"場所"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"URL"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"SMS"])
        {
            return 10;
        }
        else if ([condition isEqualToString:@"Eメール"])
        {
            return 10;
        }
    }
    else if (section == 1)
    {
        if ([condition isEqualToString:@"SMS"])
        {
            return 52;
        }
        else if ([condition isEqualToString:@"Eメール"])
        {
            return 52;
        }
    }
    
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = nil;
    UILabel *label = nil;
    if (section == 0)
    {
        if ([condition isEqualToString:@"Wi-Fiネットワーク"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"Wi-Fiネットワークの接続情報を作成します\n作成には接続先の情報が必要です";
        }
        else if ([condition isEqualToString:@"テキスト"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"テキストからコードを作成します\n文字コードや文字数に注意してください";
        }
        else if ([condition isEqualToString:@"クリップボードの内容"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"現在のクリップボードの内容から\nコードを作成します";
        }
        else if ([condition isEqualToString:@"電話番号"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"電話番号からコードを作成します\nハイフンの入力は不要です";
        }
        else if ([condition isEqualToString:@"場所"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"緯度経度からコードを作成します\n世界測地系(WGS84)座標を採用しています";
        }
        else if ([condition isEqualToString:@"URL"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"URLからコードを作成します\n大文字や文字コードに注意してください";
        }
    }
    else if (section == 1)
    {
        if ([condition isEqualToString:@"SMS"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"電話番号を宛先としたコードを作成します\nメッセージの文字数に注意してください";
        }
        else if ([condition isEqualToString:@"Eメール"])
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 40)];
            label.numberOfLines = 0;
            label.text = @"Eメールを宛先としたコードを作成します\n文字コードや文字数に注意してください";
        }
    }
    
    if (view != nil)
    {
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0];
        label.shadowOffset = CGSizeMake(0, -1);
        label.shadowColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *label = [self labelAtIndexPath:indexPath];
    if ([label isEqualToString:@"作成する"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectableCell"];
        cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else if ([label isEqualToString:@"テキストを入力"] || [label isEqualToString:@"メッセージを入力"] || [label isEqualToString:@"本文を入力"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textAreaCell"];
        placeHolder = (UILabel *)[cell viewWithTag:1];
        placeHolder.text = label;
        inputTextArea = (UITextView *)[cell viewWithTag:2];
        inputTextArea.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        inputTextArea.delegate = self;
        
        if ([condition isEqualToString:@"クリップボードの内容"])
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            inputTextArea.text = pasteboard.string;
        }
        
        if (inputTextArea.text.length > 0)
        {
            placeHolder.alpha = 0;
        }
        else
        {
            placeHolder.alpha = 1;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
        if ([label isEqualToString:@"セキュリティ"])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [GramContext get]->securityType;
            security = cell.detailTextLabel;
        }
        else if ([label isEqualToString:@"場所"])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = @"現在地";
        }
        else
        {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, cell.frame.size.height)];
            textField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.textAlignment = UITextAlignmentLeft;
            textField.delegate = self;
            if ([label isEqualToString:@"電話番号"])
            {
                textField.placeholder = @"電話番号";
                textField.keyboardType = UIKeyboardTypePhonePad;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                tel = textField;
            }
            else if ([label isEqualToString:@"宛先"])
            {
                textField.placeholder = @"メールアドレス";
                textField.keyboardType = UIKeyboardTypeEmailAddress;
                textField.returnKeyType = UIReturnKeyDone;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                mailAddress = textField;
            }
            else if ([label isEqualToString:@"件名"])
            {
                textField.placeholder = @"件名";
                textField.keyboardType = UIKeyboardTypeDefault;
                textField.returnKeyType = UIReturnKeyDone;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                subject = textField;
            }
            else if ([label isEqualToString:@"URL"])
            {
                textField.placeholder = @"URL";
                textField.keyboardType = UIKeyboardTypeURL;
                textField.returnKeyType = UIReturnKeyDone;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                url = textField;
            }
            else if ([label isEqualToString:@"SSID"])
            {
                textField.placeholder = @"ネットワーク名";
                textField.text = [[self fetchSSIDInfo] objectForKey:@"SSID"];
                textField.keyboardType = UIKeyboardTypeASCIICapable;
                textField.returnKeyType = UIReturnKeyDone;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                ssid = textField;
            }
            else if ([label isEqualToString:@"パスワード"])
            {
                textField.placeholder = @"パスワード";
                textField.keyboardType = UIKeyboardTypeASCIICapable;
                textField.returnKeyType = UIReturnKeyDone;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                password = textField;
            }
            
            cell.accessoryView = textField;
            cell.detailTextLabel.text = @"";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (inputTextArea != nil)
    {
        [inputTextArea resignFirstResponder];
    }
    
    NSString *label = [self labelAtIndexPath:indexPath];
    if ([label isEqualToString:@"作成する"])
    {
        if ([condition isEqualToString:@"電話番号"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"tel:%@", (tel.text != nil ? tel.text : @"")];
        }
        else if ([condition isEqualToString:@"Eメール"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"mailto:%@", (mailAddress.text != nil ? mailAddress.text : @"")];
        }
        else if ([condition isEqualToString:@"場所"])
        {
            CLLocation *location = nil;
            if ([GramContext get]->locationFromMap != nil)
            {
                location = [GramContext get]->locationFromMap;
            }
            else
            {
                if ([CLLocationManager locationServicesEnabled])
                {
                    if ([GramContext get]->location)
                    {
                        location = [GramContext get]->location;
                    }
                }
            }
            
            if (location != nil)
            {
                CLLocationCoordinate2D coordinate = location.coordinate;
                
                [GramContext get]->encodeString = [NSString stringWithFormat:@"geo:%f,%f", coordinate.latitude, coordinate.longitude];
            }
            else
            {
                return;
            }
        }
        else if ([condition isEqualToString:@"SMS"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"smsto:%@", (tel.text != nil ? tel.text : @"")];
            
            if (inputTextArea.text != nil)
            {
                [GramContext get]->encodeString = [NSString stringWithFormat:@"%@:%@", [GramContext get]->encodeString, inputTextArea.text];
            }
        }
        else if ([condition isEqualToString:@"URL"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"%@", (url.text != nil ? url.text : @"")];
        }
        else if ([condition isEqualToString:@"テキスト"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"%@", (inputTextArea.text != nil ? inputTextArea.text : @"")];
        }
        else if ([condition isEqualToString:@"クリップボードの内容"])
        {
            [GramContext get]->encodeString = [NSString stringWithFormat:@"%@", (inputTextArea.text != nil ? inputTextArea.text : @"")];
        }
        else if ([condition isEqualToString:@"Wi-Fiネットワーク"])
        {
            NSString *securityType = ([security.text isEqualToString:@"WPA/WPA2"] ? @"WPA" : [security.text isEqualToString:@"なし"] ? @"nopass" : security.text);
            
            if (password.text != nil)
            {
                [GramContext get]->encodeString = [NSString stringWithFormat:@"WIFI:S:%@;T:%@;P:%@;;", (ssid.text != nil ? ssid.text : @""), securityType, (password.text != nil ? password.text : @"")];
            }
            else
            {
                [GramContext get]->encodeString = [NSString stringWithFormat:@"WIFI:S:%@;T:%@;;", (ssid.text != nil ? ssid.text : @""), securityType];
            }
        }
        
        lastIndexPath = indexPath;
        [self performSegueWithIdentifier:@"createSegue" sender:self];
    }
    else
    {
        if ([label isEqualToString:@"セキュリティ"])
        {
            [GramContext get]->exportDetailCondition = label;
        }
        else if ([label isEqualToString:@"場所"])
        {
            lastIndexPath = indexPath;
            [self performSegueWithIdentifier:@"locationSegue" sender:self];
            
            return;
        }
        
        lastIndexPath = indexPath;
        [self performSegueWithIdentifier:@"detailSegue" sender:self];
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
