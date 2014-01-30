//
//  LocationManager.m
//  Monolith Works Inc.
//
//  Created by Yoshimura Kenya on 2014/01/30.
//  Copyright (c) 2014年 Yoshimura Kenya. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()
{
    CLLocationManager *locationManager;
    CLLocation *location;
}

@end

@implementation LocationManager
@synthesize delegate;

+ (LocationManager *)sharedInstance
{
    static LocationManager *instance;
    if (instance == nil) {
        instance = [LocationManager new];
    }
    
    return instance;
}

- (void)startUpdatingLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorized:
                break;
            case kCLAuthorizationStatusNotDetermined:
                break;
            case kCLAuthorizationStatusRestricted:
                break;
                
            case kCLAuthorizationStatusDenied:
                return;
        }
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
    locationManager = nil;
}

#pragma mark - Location Manager

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    location = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    location = newLocation;
    
    // delegate
    [delegate locationUpdated];
}

@end
