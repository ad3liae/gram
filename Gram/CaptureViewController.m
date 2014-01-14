//
//  CaptureViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/23.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "CaptureViewController.h"
#import "GramContext.h"

@interface NSString (NSString_Extended)
- (NSString *)matchWithPattern:(NSString *)pattern;
- (NSString *)matchWithPattern:(NSString *)pattern options:(NSInteger)options;
@end

@interface CaptureViewController ()
{
    UIView *mask;
    UIImageView *capture;
}
@end

@implementation CaptureViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    mask = [[UIView alloc] initWithFrame:self.view.frame];
    mask.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [self.view insertSubview:mask atIndex:0];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
    
    CGRect frame = activityView.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = (self.view.frame.size.height - 44) / 2 - frame.size.height / 2;
    activityView.frame = frame;
    
    [mask addSubview:activityView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //captureManager.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self activateCodeReader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)activateCodeReader
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureVideoPreviewLayer *videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    videoLayer.frame = self.view.frame;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!captureDeviceInput) {
        NSLog(@"ERROR: %@", error);
    }
    
    AVCaptureMetadataOutput *metaOutput = [[AVCaptureMetadataOutput alloc] init];
    [metaOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("myQueue.metadata", DISPATCH_QUEUE_SERIAL)];
    
    [session addInput:captureDeviceInput];
    [session addOutput:metaOutput];
    [session startRunning];
    
    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    imageView.image = [UIImage imageNamed:@"frame.png"];
    
    capture = [UIImageView new];
    capture.frame = self.view.frame;
    [capture.layer addSublayer:videoLayer];
    
    [self.view addSubview:capture];
    [self.view addSubview:imageView];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 358, 320, 40)];
    notice.numberOfLines = 0;
    notice.text = @"枠の中に収まるように\nバーコードをセットしてください";
    notice.textAlignment = UITextAlignmentCenter;
    notice.font = [UIFont systemFontOfSize:15.0];
    notice.shadowOffset = CGSizeMake(0, -1);
    notice.shadowColor = [UIColor darkGrayColor];
    notice.backgroundColor = [UIColor clearColor];
    notice.textColor = [UIColor whiteColor];
    [imageView addSubview:notice];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDidStopSelector:@selector(activateCodeReaderComplete:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    mask.alpha = 0;
    [UIView commitAnimations];
}

- (void)activateCodeReaderComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [mask removeFromSuperview];
}

#pragma mark - detecting category

- (NSString *)detectCategoryWithString:(NSString *)string
{
    NSString *type;
    if ([string matchWithPattern:@"BEGIN:VEVENT"])
    {
        type = @"イベント";
    }
    else if ([string matchWithPattern:@"BEGIN:VCARD"] || [string matchWithPattern:@"MECARD:"])
    {
        type = @"連絡先";
    }
    else if ([string matchWithPattern:@"smsto:"])
    {
        type = @"sms";
    }
    else if ([string matchWithPattern:@"tel:"])
    {
        type = @"電話番号";
    }
    else if ([string matchWithPattern:@"geo:"])
    {
        type = @"場所";
    }
    else if ([string matchWithPattern:@"mailto:"])
    {
        type = @"Eメール";
    }
    else if ([string matchWithPattern:@"://"])
    {
        type = @"URL";
    }
    else if ([string matchWithPattern:@"WIFI:"])
    {
        type = @"Wi-Fiネットワーク";
    }
    else if ([string matchWithPattern:@"^[0-9]*$"])
    {
        //type = @"その他";
        type = @"テキスト";
    }
    else
    {
        type = @"テキスト";
    }
    
    return type;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *data in metadataObjects) {
        if (![data isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
            continue;
        
        NSString *strValue = [(AVMetadataMachineReadableCodeObject *)data stringValue];
        NSLog(@"%@ <%@>", strValue, data.type);
        
        if ([data.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSURL *url = [NSURL URLWithString:strValue];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else if([data.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            long long value = strValue.longLongValue;
            NSInteger prefix = value / 10000000000;
            
            // ISBN
            if (prefix == 978 || prefix == 979) {
                long long isbn9 = (value % 10000000000) / 10;
                long long sum = 0, tmp_isbn = isbn9;
                for (int i=10; i>0 && tmp_isbn>0; i--) {
                    long long divisor = pow(10, i-2);
                    sum += (tmp_isbn / divisor) * i;
                    tmp_isbn %= divisor;
                }
                long long checkdigit = 11 - (sum % 11);
                
                NSString *asin = [NSString stringWithFormat:@"http://amazon.jp/dp/%lld%@", isbn9, (checkdigit == 10) ? @"X" : [NSString stringWithFormat:@"%lld", checkdigit % 11]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:asin]];
            }
            
        }
    }
}

/*
#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result
{
    if (result)
    {
        CVImageBufferRef imageBuffer = [capture captureFrame];
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width       = CVPixelBufferGetWidth(imageBuffer);
        size_t height      = CVPixelBufferGetHeight(imageBuffer);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
        UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
 
        NSDate *date = [NSDate date];
        
        CLLocation *location = nil;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        if ([settings boolForKey:@"USE_LOCATION"])
        {
            if ([CLLocationManager locationServicesEnabled])
            {
                if ([GramContext get]->location)
                {
                    location = [GramContext get]->location;
                }
            }
        }
        NSLog(@"barcodeFormat %d", [result barcodeFormat]);
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *name = [NSString stringWithFormat:@"%f", [date timeIntervalSinceReferenceDate]];
        [self save:imageData name:name];
        
        NSArray *keys = [NSArray arrayWithObjects:@"type", @"category", @"image", @"format", @"text", @"date", @"location", nil];
        NSArray *datas = [NSArray arrayWithObjects:@"decode", [self detectCategoryWithString:[result text]], name, [NSNumber numberWithInt:[result barcodeFormat]], [result text], [NSDate dateWithTimeIntervalSinceReferenceDate:[result timestamp]], [NSKeyedArchiver archivedDataWithRootObject:location], nil];
        
        if ([settings boolForKey:@"CONTINUOUS_MODE"])
        {
            if ([GramContext get]->captured != nil)
            {
                if ([[[GramContext get]->captured objectForKey:@"text"] isEqualToString:[result text]])
                {
                    return;
                }
            }
        }
        
        [GramContext get]->sharedCompleted = NO;
        [GramContext get]->captured = [NSDictionary dictionaryWithObjects:datas forKeys:keys];
        [[GramContext get]->history insertObject:[GramContext get]->captured atIndex:0];
        
        [settings setObject:[[GramContext get]->history copy] forKey:@"HISTORY"];
        [settings synchronize];
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        if ([settings boolForKey:@"CONTINUOUS_MODE"])
        {
            
        }
        else
        {
            
            
            if (delegate != nil)
            {
                [delegate dismissCameraView];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)captureSize:(ZXCapture *)capture width:(NSNumber *)width height:(NSNumber *)height
{
    
}
*/

- (IBAction)tapCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(NSData *)image name:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:name];
    [image writeToFile:path atomically:YES];
}

@end

#pragma mark - NSString extended

@implementation NSString (NSString_Extended)

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

@end