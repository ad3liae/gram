//
//  GramAnnotation.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/24.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GramAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSDictionary *dictionary;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle;
-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle withData:(NSDictionary *)dictionary;

@end