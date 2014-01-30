//
//  CaptureViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/23.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "CaptureViewController.h"

#import "LocationManager.h"
#import "ImageManager.h"

#import "NSString+MWORKS.h"

@interface CaptureViewController ()
{
    UIView *mask;
    UIView *preview;
    BOOL ready;
    BOOL captured;
    AVMetadataObject *metadata;
}
@end

@implementation CaptureViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings boolForKey:@"USE_LOCATION"]) {
        [[LocationManager sharedInstance] startUpdatingLocation];
    }
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
}

- (void)activateCodeReader
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset1280x720;
    
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
    
    NSDictionary* settings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = settings;
    dataOutput.alwaysDiscardsLateVideoFrames = YES;
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [session addInput:captureDeviceInput];
    [session addOutput:metaOutput];
    [session addOutput:dataOutput];
    [session startRunning];
    
    metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code];
    
    UIImageView *container = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    container.image = [UIImage imageNamed:@"frame.png"];
    
    preview = [UIView new];
    preview.frame = self.view.frame;
    [preview.layer addSublayer:videoLayer];
    
    [self.view addSubview:preview];
    [self.view addSubview:container];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 358, 320, 40)];
    notice.numberOfLines = 0;
    notice.text = @"枠の中に収まるように\nバーコードをセットしてください";
    notice.textAlignment = NSTextAlignmentCenter;
    notice.font = [UIFont systemFontOfSize:15.0];
    notice.shadowOffset = CGSizeMake(0, -1);
    notice.shadowColor = [UIColor darkGrayColor];
    notice.backgroundColor = [UIColor clearColor];
    notice.textColor = [UIColor whiteColor];
    [container addSubview:notice];
    
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

- (id)transformedCMTime:(CMTime)time
{
    Float64 seconds = CMTimeGetSeconds(time);
    seconds -= [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (ready) {
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        
        NSString *stringValue = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
        
        if ([settings boolForKey:@"CONTINUOUS_MODE"])
        {
            if ([GramContext get]->captured != nil)
            {
                if ([[[GramContext get]->captured objectForKey:@"text"] isEqualToString:stringValue])
                {
                    return;
                }
            }
        }
        
        ready = NO;
        captured = YES;
        
        UIImage *image = [self imageFromSampleBufferRef:sampleBuffer];
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor redColor];
        imageView.frame = CGRectMake(0, 0, image.size.width / 4, image.size.height / 4);
        imageView.image = image;
        [self.view addSubview:imageView];
        
        CLLocation *location = nil;
        if ([settings boolForKey:@"USE_LOCATION"]) {
            location = [[LocationManager sharedInstance] getLocation];
        }
        
        NSDate *date = [self transformedCMTime:metadata.time];
        NSString *identifier = [[NSUUID new] UUIDString];
        [[ImageManager sharedInstance] saveImage:image identifier:identifier];
        
        NSDictionary *object = @{
            @"id"       : identifier,
            @"type"     : @"decode",
            @"category" : [self detectCategoryWithString:stringValue],
            @"format"   : metadata.type,
            @"text"     : stringValue,
            @"date"     : date,
            @"location" : [NSKeyedArchiver archivedDataWithRootObject:location]
        };
        
        [GramContext get]->sharedCompleted = NO;
        [GramContext get]->captured = object;
        [[GramContext get]->history addObject:object];
        
        [settings setObject:[[GramContext get]->history copy] forKey:@"HISTORY"];
        [settings synchronize];
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        if ([settings boolForKey:@"CONTINUOUS_MODE"])
        {
            
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *data in metadataObjects) {
        if (![data isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            continue;
        }
        
        if (captured) {
            continue;
        }
        
        ready = YES;
        
        NSString *strValue = [(AVMetadataMachineReadableCodeObject *)data stringValue];
        NSLog(@"%@ <%@>", strValue, data.type);
        
        if ([data.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSURL *url = [NSURL URLWithString:strValue];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                //[[UIApplication sharedApplication] openURL:url];
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

- (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBuffer
{
    AVCaptureVideoOrientation orientation = UIImageOrientationRight;
    
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:orientation];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return image;
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