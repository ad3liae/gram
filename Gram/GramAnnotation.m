//
//  GramAnnotation.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/24.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "GramAnnotation.h"
#import "GramContext.h"

@implementation GramAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize dictionary = _dictionary;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	_coordinate = coordinate;
    
	return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle
{
	_coordinate = coordinate;
    _title = title;
    _subTitle = subTitle;
    
	return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle withData:(NSDictionary *)dictionary
{
	_coordinate = coordinate;
    _title = title;
    _subTitle = subTitle;
    _dictionary = dictionary;
    
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
    NSLog(@"setCoordinate");
    [GramContext get]->locationFromMap = [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
}

- (NSString *)title
{
    return _title;
}

- (NSString *)subtitle
{
    return _subTitle;
}

- (NSDictionary *)dictionary
{
    return _dictionary;
}

@end