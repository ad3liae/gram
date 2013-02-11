//
//  DetailViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/09/05.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "DetailViewController.h"
#import "GramContext.h"
#import "UITabBarWithAdController.h"

@interface NSString (NSString_Extended)
- (NSString *)urlencode;
- (NSString *)matchWithPattern:(NSString *)pattern;
- (NSString *)matchWithPattern:(NSString *)pattern options:(NSInteger)options;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace options:(NSInteger)options;
@end

@interface DetailViewController ()
{
    NSMutableArray *labels;
    NSMutableArray *values;
    NSMutableData *receivedData;
    NSString *url;
    BOOL completed;
    BOOL redirected;
    NSInteger statusCode;
    NSString *advice;
    NSString *content;
    CGRect frame;
    BOOL isAppeared;
    CGSize blockSize;
}

@end

@implementation DetailViewController
@synthesize phase = _phase;
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
    self.title = @"インポート";
    isAppeared = NO;

    if (![_phase isEqualToString:@"history"])
    {
        [self buildFromData:[GramContext get]->captured];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_phase isEqualToString:@"history"])
    {
        [self buildFromData:[GramContext get]->decodeFromHistory];
    }
    else
    {
        [self buildFromData:[GramContext get]->captured];
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
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.delegate == self)
    {
        tabBar.delegate = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    if (tabBar.delegate != self)
    {
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
    
    if (isAppeared != YES)
    {
        isAppeared = YES;
        
        if (url != nil)
        {
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (connection)
            {
                NSLog(@"start loading");
                completed = NO;
                redirected = NO;
                receivedData = [NSMutableData data];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"receive response");
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
	NSLog(@"%d", [res statusCode]);
    
    statusCode = [res statusCode];
    switch(statusCode)
    {
        case 301:
        case 302:
        case 303:
            redirected = YES;
            break;
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    //NSLog(@"receive data");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSHTTPURLResponse *)redirectResponse
{
    NSURLRequest *newRequest = request;
    if (redirectResponse)
    {
        NSLog(@"willSendRequest URL:%@", [[request URL] absoluteString]);
        url = [[request URL] absoluteString];
        
        [[labels objectAtIndex:0] addObject:@"->"];
        [[values objectAtIndex:0] addObject:[url copy]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[labels objectAtIndex:0] count] - 1) inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //[self.tableView reloadData];
        newRequest = nil;
    }
    return newRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"received %d bytes of data",[receivedData length]);
    NSString *content = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if (completed)
    {
        BOOL isPhishing;
        BOOL isMalware;
        if ([content matchWithPattern:@"phishing"])
        {
            NSLog(@"detecting phishing site");
            isPhishing = YES;
            advice = @"フィッシング詐欺サイトとして報告されています。";
        }
        if ([content matchWithPattern:@"malware"])
        {
            NSLog(@"detecting malware site");
            isMalware = YES;
            if (advice != nil)
            {
                advice = [NSString stringWithFormat:@"%@\nマルウェア配布サイトとして報告されています。", advice];
            }
            else
            {
                advice = @"マルウェア配布サイトとして報告されています。";
            }
        }
        
        [[labels objectAtIndex:0] addObject:@"安全性"];
        
        if (advice != nil)
        {
            NSLog(@"%@", advice);
            [[values objectAtIndex:0] addObject:advice];
        }
        else
        {
            [[values objectAtIndex:0] addObject:@"問題なし"];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[labels objectAtIndex:0] count] - 1) inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        url = nil;
        
        return;
    }
    
    if (redirected)
    {
        redirected = NO;
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            NSLog(@"redirected start loading");
            receivedData = [NSMutableData data];
        }
    }
    else
    {
        completed = YES;
        NSString *urlEncodedString = [url urlencode];
        NSString *address = [NSString stringWithFormat:@"%s%@", "https://sb-ssl.google.com/safebrowsing/api/lookup?client=api&apikey=ABQIAAAANUiT3dCqiRdMYYSnaf-RUBR9ApE11fhAA1_rJw473ZQ8OtPTMQ&appver=1.0&pver=3.0&url=", urlEncodedString];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            NSLog(@"start loading");
            receivedData = [NSMutableData data];
        }
    }
}

#pragma mark - custom methods

- (CGSize)calculateLabelBlockSize:(NSString *)text
{
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    CGSize value = [text sizeWithFont:font constrainedToSize:CGSizeMake(210, 1000) lineBreakMode:UILineBreakModeCharacterWrap];

    return value;
}

- (CGSize)calculateLabelBlockSize:(NSString *)text frameSize:(CGFloat)width
{
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    CGSize value = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    
    return value;
}

- (CGSize)calculateTextBlockSize:(NSString *)text
{
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CGSize value = [text sizeWithFont:font constrainedToSize:CGSizeMake(210, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    
    return value;
}

- (NSString *)formatFromId:(id)index
{
    NSString *number = [NSString stringWithFormat:@"%@", index];
    if ([number isEqualToString:@"0"])
    {
        return @"Aztec";
    }
    else if ([number isEqualToString:@"1"])
    {
        return @"CODABAR";
    }
    else if ([number isEqualToString:@"2"])
    {
        return @"Code 39";
    }
    else if ([number isEqualToString:@"3"])
    {
        return @"Code 93";
    }
    else if ([number isEqualToString:@"4"])
    {
        return @"Code 128";
    }
    else if ([number isEqualToString:@"5"])
    {
        return @"Data Matrix";
    }
    else if ([number isEqualToString:@"6"])
    {
        return @"EAN-8";
    }
    else if ([number isEqualToString:@"7"])
    {
        return @"EAN-13";
    }
    else if ([number isEqualToString:@"8"])
    {
        return @"ITF";
    }
    else if ([number isEqualToString:@"9"])
    {
        return @"MaxiCode";
    }
    else if ([number isEqualToString:@"10"])
    {
        return @"PDF417";
    }
    else if ([number isEqualToString:@"11"])
    {
        return @"QR Code";
    }
    else if ([number isEqualToString:@"12"])
    {
        return @"RSS 14";
    }
    else if ([number isEqualToString:@"13"])
    {
        return @"RSS EXPANDED";
    }
    else if ([number isEqualToString:@"14"])
    {
        return @"UPC-A";
    }
    else if ([number isEqualToString:@"15"])
    {
        return @"UPC-E";
    }
    else if ([number isEqualToString:@"16"])
    {
        return @"UPC/EAN extension";
    }
    
    return [NSString stringWithFormat:@"%@", index];
}

-(void)buildFromData:(NSDictionary *)data
{
    labels = [NSMutableArray array];
    values = [NSMutableArray array];
    
    if ([self.tableView viewWithTag:1] != nil)
        [[self.tableView viewWithTag:1] removeFromSuperview];
    
    if (data != nil)
    {
        content = [NSString stringWithFormat:@"コード種別\n%@\n\n内容\n%@", [self formatFromId:[data objectForKey:@"format"]], [data objectForKey:@"text"]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSURL *entryURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:[data objectForKey:@"image"]]];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[entryURL path]];
        CGFloat ratio = image.size.width / image.size.height;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 140 * (ratio < 1 ? ratio : 1), 140 * (ratio < 1 ? 1 : ratio))];
        imageView.tag = 1;
        imageView.image = image;
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [self.tableView addSubview:imageView];
        
        blockSize = [self calculateLabelBlockSize:content frameSize:320 - 140 * (ratio < 1 ? ratio : 1) - 60];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(140 * (ratio < 1 ? ratio : 1) + 20, 0, 320 - 140 * (ratio < 1 ? ratio : 1) - 60, blockSize.height)];
        label.numberOfLines = 0;
        label.text = content;
        label.textAlignment = UITextAlignmentLeft;
        label.lineBreakMode = UILineBreakModeCharacterWrap;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.shadowOffset = CGSizeMake(0, -1);
        label.shadowColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [imageView addSubview:label];
        
        url = [[data objectForKey:@"text"] matchWithPattern:@"https?:\\/\\/[^ \t\r\n;　]+"];
        if (url != nil)
        {
            [labels addObject:[NSMutableArray arrayWithObject:@"URL"]];
            [values addObject:[NSMutableArray arrayWithObject:url]];
        }
        
        NSString *sms = [[data objectForKey:@"text"] matchWithPattern:@"smsto:[^ \t\r\n:;　]+" options:NSRegularExpressionCaseInsensitive];
        if (sms != nil)
        {
            sms = [sms matchWithPattern:@"smsto:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            NSString *message = [[data objectForKey:@"text"] matchWithPattern:@"smsto:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            message = [message matchWithPattern:@"smsto:[0-9]*:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            [labels addObject:[NSMutableArray arrayWithObjects:@"電話番号", @"メッセージ", nil]];
            [values addObject:[NSMutableArray arrayWithObjects:sms, message, nil]];
        }
        NSString *mail = [[data objectForKey:@"text"] matchWithPattern:@"mailto:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
        NSString *body = nil;
        NSString *subject = nil;
        if (mail != nil)
        {
            mail = [mail matchWithPattern:@"MAILTO:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            body = [[data objectForKey:@"text"] matchWithPattern:@"body:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            if (body != nil)
            {
                body = [body matchWithPattern:@"BODY:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            }
            else
            {
                body = @"";
            }
            
            subject = [[data objectForKey:@"text"] matchWithPattern:@"subject:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            if (subject != nil)
            {
                subject = [subject matchWithPattern:@"SUBJECT:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            }
            else
            {
                subject = @"";
            }
            [labels addObject:[NSMutableArray arrayWithObjects:@"Eメール", @"件名", @"本文", nil]];
            [values addObject:[NSMutableArray arrayWithObjects:mail, subject, body, nil]];
            /*
             if (![body isEqualToString:@""] || ![subject isEqualToString:@""])
             {
             NSLog(@"%@", [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, subject, body]);
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, subject, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
             }
             else
             {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"mailto:%@", mail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
             }
             */
            return;
        }
        
        NSString *tel = [[data objectForKey:@"text"] matchWithPattern:@"tel:[^ \t\r\n:;　]+" options:NSRegularExpressionCaseInsensitive];
        if (tel != nil)
        {
            tel = [tel matchWithPattern:@"tel:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            [labels addObject:[NSMutableArray arrayWithObject:@"電話番号"]];
            [values addObject:[NSMutableArray arrayWithObject:tel]];
        }
        
        NSString *mailAddress = [(NSString *)[[data objectForKey:@"text"] matchWithPattern:@"email:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive] matchWithPattern:@"email:" replace:@"" options:NSRegularExpressionCaseInsensitive];
        
        if (mailAddress != nil)
        {
            if (tel != nil)
            {
                [[labels lastObject] addObject:@"Eメール"];
                [[values lastObject ] addObject:mailAddress];
            }
            else
            {
                [labels addObject:[NSMutableArray arrayWithObject:@"Eメール"]];
                [values addObject:[NSMutableArray arrayWithObject:mailAddress]];
            }
        }
        
        if ([labels count] == 0)
        {
            [labels addObject:[NSMutableArray arrayWithObject:@"テキスト"]];
            [values addObject:[NSMutableArray arrayWithObject:[data objectForKey:@"text"]]];
        }
        
        [labels addObject:[NSMutableArray arrayWithObjects:@"Eメールで送信", @"ツイッターで共有", @"フェイスブックで共有", @"クリップボードにコピー", nil]];
        
        //NSString *string = [NSString stringWithFormat:@"http://www.amazon.co.jp/s/ref=nb_sb_noss_2?__mk_ja_JP=%@&url=search-alias%%3Daps&field-keywords=%@&x=0&Ay=0", [data objectForKey:@"text"], [data objectForKey:@"text"]];
        //NSLog(@"%@", string);
        //NSURL *path = [NSURL URLWithString:string];
        //NSURLRequest *req = [NSURLRequest requestWithURL:path];
        //UIWebView *webView = [[UIWebView alloc] init];
        //webView.delegate = self;
        //[webView loadRequest:req];
        //[self.view addSubview:webView];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.co.jp/products?q=%@", [data objectForKey:@"text"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        //http://www.amazon.co.jp/gp/search/?__mk_ja_JP=%83J%83%5E%83J%83i&field-keywords=
        //http://www.amazon.co.jp/gp/search/?__mk_ja_JP=%83J%83%5E%83J%83i&url=search-alias%3D【カテゴリー名】&field-keywords=【商品名】
        //apsでall
        //http://www.amazon.co.jp/s/ref=nb_sb_noss_2?__mk_ja_JP=%s&url=search-alias%3Daps&field-keywords=%s&x=0&Ay=0
        
        if (![_phase isEqualToString:@"history"])
        {
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            if ([settings boolForKey:@"AUTOMATIC_MODE"] == YES)
            {
                if (url != nil)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
                else if (mail != nil)
                {
                    if (![body isEqualToString:@""] || ![subject isEqualToString:@""])
                    {
                        NSLog(@"%@", [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, subject, body]);
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, subject, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"mailto:%@", mail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                }
                else if (sms != nil)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", sms]]];
                }
                /*else if (tel != nil)
                 {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
                 }*/
            }
        }
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (blockSize.height > 160)
        {
            return blockSize.height + 40;
        }
        return 180;
    }
    
    return tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height;
    
    switch (indexPath.section)
    {
        case 0:
            height = [self calculateTextBlockSize:[[values objectAtIndex:0] objectAtIndex:indexPath.row]].height;
            
            return (19 > height ? 44 : height + 25);
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    @try {
        NSString *value = [[values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        UILabel *detail = (UILabel *)[cell viewWithTag:2];
        detail.frame = CGRectMake(83, 12, 210, [self calculateTextBlockSize:[[values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]].height);
        detail.lineBreakMode = UILineBreakModeCharacterWrap;
        detail.text = value;
    }
    @catch (NSException *exception) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectableCell"];
        cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (![_phase isEqualToString:@"history"])
    {
        if (index == 0)
        {
            [GramContext get]->captured = nil;
            [GramContext get]->bootCompleted = YES;
            
            [self.navigationController popViewControllerAnimated:YES];
            return NO;
        }
    }
    return YES;
}

#pragma mark - action sheet delegate

- (IBAction)tapAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"キャンセル"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"画像を保存する", @"コードを表示する", nil];
    [actionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        default:
            break;
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

#pragma mark - NSString extended

@implementation NSString (NSString_Extended)

- (NSString *)urlencode
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i)
    {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ')
        {
            [output appendString:@"+"];
        }
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9'))
        {
            [output appendFormat:@"%c", thisChar];
        }
        else
        {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)matchWithPattern:(NSString *)pattern
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error);
    }
    else
    {
        NSTextCheckingResult *match = [regexp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
        if (match.numberOfRanges > 0)
        {
            //NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
            return [self substringWithRange:[match rangeAtIndex:0]];
        }
    }
    
    return nil;
}

- (NSString *)matchWithPattern:(NSString *)pattern options:(NSInteger)options
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:options
                                                error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error);
    }
    else
    {
        NSTextCheckingResult *match = [regexp firstMatchInString:self options:options range:NSMakeRange(0, self.length)];
        if (match.numberOfRanges > 0)
        {
            //NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
            return [self substringWithRange:[match rangeAtIndex:0]];
        }
    }
    
    return nil;
}

- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    NSString *replaced =
    [regexp stringByReplacingMatchesInString:self
                                     options:0
                                       range:NSMakeRange(0,self.length)
                                withTemplate:replace];

    //NSLog(@"%@",replaced);
    return replaced;
}

- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace options:(NSInteger)options
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:options
                                                error:&error];
    NSString *replaced =
    [regexp stringByReplacingMatchesInString:self
                                     options:options
                                       range:NSMakeRange(0,self.length)
                                withTemplate:replace];
    
    //NSLog(@"%@",replaced);
    return replaced;
}

@end
