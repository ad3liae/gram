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
    NSString *condition;
    NSMutableArray *labels;
    NSMutableArray *values;
    NSMutableData *receivedData;
    NSString *url;
    BOOL completed;
    BOOL redirected;
    NSInteger statusCode;
    NSString *advice;
    CGRect frame;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    condition = @"URL";
    labels = [NSMutableArray arrayWithObjects:[NSMutableArray array], nil];
    values = [NSMutableArray arrayWithObjects:[NSMutableArray array], nil];
    
    NSDictionary *data = nil;
    if ([_phase isEqualToString:@"history->detail"])
    {
        data = [GramContext get]->decodeFromHistory;
    }
    else
    {
        data = [GramContext get]->captured;
    }
    
    if (data != nil)
    {
        url = [[data objectForKey:@"text"] matchWithPattern:@"https?:\\/\\/[^ \t\r\n;　]+"];
        if (url != nil)
        {
            [[labels objectAtIndex:0] addObject:@"URL"];
            [[values objectAtIndex:0] addObject:[url copy]];
            [self.tableView reloadData];
            return;
        }
        
        NSString *tel = [[data objectForKey:@"text"] matchWithPattern:@"tel:[^ \t\r\n:;　]+" options:NSRegularExpressionCaseInsensitive];
        if (tel != nil)
        {
            tel = [tel matchWithPattern:@"tel:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            [[labels objectAtIndex:0] addObject:@"電話番号"];
            [[values objectAtIndex:0] addObject:[tel copy]];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
        }
        
        NSString *sms = [[data objectForKey:@"text"] matchWithPattern:@"smsto:[^ \t\r\n:;　]+" options:NSRegularExpressionCaseInsensitive];
        if (sms != nil)
        {
            sms = [sms matchWithPattern:@"smsto:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            NSString *message = [[data objectForKey:@"text"] matchWithPattern:@"smsto:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            message = [message matchWithPattern:@"smsto:[0-9]*:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            [[labels objectAtIndex:0] addObject:@"電話番号"];
            [[values objectAtIndex:0] addObject:[sms copy]];
            [[labels objectAtIndex:0] addObject:@"メッセージ"];
            [[values objectAtIndex:0] addObject:[message copy]];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", sms]]];
        }
        NSString *mail = [[data objectForKey:@"text"] matchWithPattern:@"mailto:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
        if (mail != nil)
        {
            mail = [mail matchWithPattern:@"MAILTO:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            NSString *body = [[data objectForKey:@"text"] matchWithPattern:@"body:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            if (body != nil)
            {
                body = [body matchWithPattern:@"BODY:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            }
            else
            {
                body = @"";
            }
            
            NSString *subject = [[data objectForKey:@"text"] matchWithPattern:@"subject:[^ \t\r\n;　]+" options:NSRegularExpressionCaseInsensitive];
            if (subject != nil)
            {
                subject = [subject matchWithPattern:@"SUBJECT:" replace:@"" options:NSRegularExpressionCaseInsensitive];
            }
            else
            {
                subject = @"";
            }
            [[labels objectAtIndex:0] addObject:@"Eメール"];
            [[values objectAtIndex:0] addObject:[mail copy]];
            [[labels objectAtIndex:0] addObject:@"件名"];
            [[values objectAtIndex:0] addObject:[subject copy]];
            [[labels objectAtIndex:0] addObject:@"本文"];
            [[values objectAtIndex:0] addObject:[body copy]];
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
        
        [[labels objectAtIndex:0] addObject:@"テキスト"];
        [[values objectAtIndex:0] addObject:[data objectForKey:@"text"]];
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
    if (url != nil)
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            NSLog(@"start loading");
            receivedData = [NSMutableData data];
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
    NSLog(@"receive data");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
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
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
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
            [[values objectAtIndex:0] addObject:@"問題は検知しませんでした"];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[labels objectAtIndex:0] count] - 1) inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
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
    float height;
    
    switch (indexPath.section)
    {
        case 0:
            height = (int)[self calculateTextBlockSize:[[values objectAtIndex:0] objectAtIndex:indexPath.row]].height;
            return ((44 - 25) > height ? 44 : height + 25);
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UILabel *detail = (UILabel *)[cell viewWithTag:2];
    detail.frame = CGRectMake(83, 12, 210, (int)[self calculateTextBlockSize:[[values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]].height);
    detail.text = [[values objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGSize)calculateTextBlockSize:(NSString *)text
{
    CGSize size;
    CGSize value;
    UIFont *font;
    
    font = [UIFont boldSystemFontOfSize:15];
    size = CGSizeMake(220, 1000);
    value = [text sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeCharacterWrap];
    
    return value;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (![_phase isEqualToString:@"history->detail"])
    {
        NSLog(@"%d", index);
        if (index == 0)
        {
            [GramContext get]->captured = nil;
            [GramContext get]->bootCompleted = YES;
            
            [self.navigationController popViewControllerAnimated:YES];
            //[self performSegueWithIdentifier:@"captureSegue" sender:self];
            return NO;
        }
    }
    return YES;
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
            NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
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
            NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
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
    
    NSLog(@"%@",replaced);
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
    
    NSLog(@"%@",replaced);
    return replaced;
}

@end
