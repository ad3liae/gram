//
//  LocationManager.h
//  Monolith Works Inc.
//
//  Created by Yoshimura Kenya on 2014/01/30.
//  Copyright (c) 2014年 Yoshimura Kenya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@required
- (void)locationUpdated;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, retain) id<LocationManagerDelegate> delegate;

+ (LocationManager *)sharedInstance;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
