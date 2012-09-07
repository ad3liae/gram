//
//  GramContext.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/21.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GramContext : NSObject
{
    @public
    NSString *condition;
    CLLocation *location;
    NSMutableArray *history;
    NSDictionary *decodeFromHistory;
    NSDictionary *encodeFromHistory;
    NSDictionary *captured;
    NSDictionary *generated;
    BOOL sharedCompleted;
    NSString *encodeString;
    NSString *encodeType;
    NSString *exportCondition;
    NSString *exportDetailCondition;
    CLLocation *locationFromMap;
    NSString *securityType;
    BOOL bootCompleted;
    NSString *importMode;
    NSString *exportMode;
    NSString *exportModeFromHistory;
}

+ (GramContext *)get;

@end
