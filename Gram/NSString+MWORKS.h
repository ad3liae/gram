//
//  NSString+MWORKS.h
//  Monolith Works Inc.
//
//  Created by Yoshimura Kenya on 2014/01/24.
//  Copyright (c) 2014年 STG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MWORKS)

- (NSString *)urlencode;
- (NSString *)urlencodeLiterally:(BOOL)literally;
- (NSString *)encodeHtmlEntities;
- (NSString *)urldecode;
- (NSString *)decodeHtmlEntities;
- (NSString *)matchWithPattern:(NSString *)pattern;
- (NSString *)matchWithPattern:(NSString *)pattern options:(NSInteger)options;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace;
- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace options:(NSInteger)options;
- (CGSize)calculateBoldBlockSize:(NSInteger)fontSize;
- (CGSize)calculateBoldBlockSize:(NSInteger)fontSize width:(CGFloat)width;
- (CGSize)calculateBlockSize:(NSInteger)fontSize;
- (CGSize)calculateBlockSize:(NSInteger)fontSize width:(CGFloat)width;

@end
