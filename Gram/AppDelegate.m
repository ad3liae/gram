//
//  AppDelegate.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/07/27.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "AppDelegate.h"
#import "GramContext.h"
#import "ZXEncodeHints.h"

@interface AppDelegate ()
{
    CLLocationManager *locationManager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GramContext get]->history = [NSMutableArray array];
    [GramContext get]->location = nil;
    [GramContext get]->bootCompleted = NO;
    if ([CLLocationManager locationServicesEnabled])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *keys = [NSArray arrayWithObjects:@"HISTORY", @"INSTANT_BOOT_MODE", @"AUTOMATIC_MODE", @"CONTINUOUS_MODE", @"USE_LOCATION", @"QR_ERROR_CORRECTION_LEVEL", @"IMPORT_MODE", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSArray array], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], @"L", @"自動判別", nil];
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [settings registerDefaults:defaults];
    
    [GramContext get]->history = [NSMutableArray arrayWithArray:[settings arrayForKey:@"HISTORY"]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"update");
    [GramContext get]->location = newLocation;
}

@end
