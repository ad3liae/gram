//
//  CaptureViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/23.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>

@interface CaptureViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, retain) id delegate;
- (IBAction)tapCancel:(id)sender;

@end
