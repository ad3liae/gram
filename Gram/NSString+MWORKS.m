//
//  NSString+MWORKS.m
//  Monolith Works Inc.
//
//  Created by Yoshimura Kenya on 2014/01/24.
//  Copyright (c) 2014年 Yoshimura Kenya. All rights reserved.
//

#import "NSString+MWORKS.h"

@implementation NSString (MWORKS)

- (NSString *)urlencode
{
    return [self urlencodeLiterally:NO];
}

- (NSString *)urlencodeLiterally:(BOOL)literally
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i)
    {
        const unsigned char thisChar = source[i];
        if (!literally && thisChar == ' ')
        {
            [output appendString:@"+"];
        }
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                 (thisChar >= 'a' && thisChar <= 'z') ||
                 (thisChar >= 'A' && thisChar <= 'Z') ||
                 (thisChar >= '0' && thisChar <= '9'))
        {
            [output appendFormat:@"%c", thisChar];
        }
        else
        {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)urldecode
{
    NSString *target = self;
    target = [target stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    target = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                    (CFStringRef)target,
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8));
    return target;
}

// Decodes only selective entities (as CFXMLParser would) plus some more.
// http://www.opensource.apple.com/source/CF/CF-550/CFXMLParser.c
- (NSString *)decodeHtmlEntities {
    NSMutableString *const target = [self mutableCopy];
    [target replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&#13;" withString:@"\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"&#10;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    return target;
}

- (NSString *)encodeHtmlEntities {
    NSMutableString *const target = [self mutableCopy];
    [target replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"\r" withString:@"&#13;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    [target replaceOccurrencesOfString:@"\n" withString:@"&#10;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, target.length)];
    return target;
}

- (NSString *)matchWithPattern:(NSString *)pattern
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    if (error != nil)
    {
        //NSLog(@"%@", error);
    }
    else
    {
        NSTextCheckingResult *match = [regexp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
        if (match.numberOfRanges > 0)
        {
            //NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
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
        //NSLog(@"%@", error);
    }
    else
    {
        NSTextCheckingResult *match = [regexp firstMatchInString:self options:options range:NSMakeRange(0, self.length)];
        if (match.numberOfRanges > 0)
        {
            //NSLog(@"%@", [self substringWithRange:[match rangeAtIndex:0]]);
            return [self substringWithRange:[match rangeAtIndex:0]];
        }
    }
    
    return nil;
}

- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    NSString *replaced =
    [regexp stringByReplacingMatchesInString:self
                                     options:0
                                       range:NSMakeRange(0,self.length)
                                withTemplate:replace];
    
    //NSLog(@"%@",replaced);
    return replaced;
}

- (NSString *)matchWithPattern:(NSString *)pattern replace:(NSString *)replace options:(NSInteger)options
{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:options
                                                error:&error];
    NSString *replaced =
    [regexp stringByReplacingMatchesInString:self
                                     options:options
                                       range:NSMakeRange(0,self.length)
                                withTemplate:replace];
    
    //NSLog(@"%@",replaced);
    return replaced;
}

- (CGSize)calculateBoldBlockSize:(NSInteger)fontSize
{
    return [self calculateBoldBlockSize:fontSize width:CGFLOAT_MAX];
}

- (CGSize)calculateBoldBlockSize:(NSInteger)fontSize width:(CGFloat)width
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        UIFont *font;
        NSString *string;
        
        font = [UIFont boldSystemFontOfSize:fontSize];
        string = self;
        if ([string isEqualToString:@""])
        {
            string = @"　";
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:font}];
        
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)
                                                   context:nil];
        
        return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
    }
    else
    {
        CGSize size;
        CGSize value;
        UIFont *font;
        
        font = [UIFont boldSystemFontOfSize:fontSize];
        size = CGSizeMake(width, CGFLOAT_MAX);
        if ([self isEqualToString:@""])
        {
            NSString *dummy = @"　";
            value = [dummy sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        }
        else
            value = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        
        return value;
    }
}

- (CGSize)calculateBlockSize:(NSInteger)fontSize
{
    return [self calculateBlockSize:fontSize width:CGFLOAT_MAX];
}

- (CGSize)calculateBlockSize:(NSInteger)fontSize width:(CGFloat)width
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        UIFont *font;
        NSString *string;
        
        font = [UIFont systemFontOfSize:fontSize];
        string = self;
        if ([string isEqualToString:@""])
        {
            string = @"　";
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:font}];
        
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine)
                                                   context:nil];
        
        return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
    }
    else
    {
        CGSize size;
        CGSize value;
        UIFont *font;
        
        font = [UIFont systemFontOfSize:fontSize];
        size = CGSizeMake(width, CGFLOAT_MAX);
        if ([self isEqualToString:@""])
        {
            NSString *dummy = @"　";
            value = [dummy sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        }
        else
            value = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        
        return value;
    }
}

@end
