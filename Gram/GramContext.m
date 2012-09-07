//
//  GramContext.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/21.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "GramContext.h"

@implementation GramContext

+ (GramContext *)get
{
    static GramContext *ctx;
    if (ctx == nil)
        ctx = [GramContext new];
    return ctx;
}

@end
