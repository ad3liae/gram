//
//  ImageManager.h
//  News
//
//  Created by Kenya Yoshimura on 2013/11/04.
//  Copyright (c) 2013年 Monolith Works Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageCacheResultBlock)(UIImage *image, NSString *url, NSError *error);

@interface ImageManager : NSObject

+ (ImageManager *)sharedInstance;
+ (NSString *)getLocalURL:(NSString *)URL;

- (UIImage *)imageWithURL:(NSString *)URL block:(ImageCacheResultBlock)block;
- (UIImage *)imageWithURL:(NSString *)URL defaultImage:(UIImage *)defaultImage block:(ImageCacheResultBlock)block;
- (UIImage *)thumbnailWithURL:(NSString *)URL block:(ImageCacheResultBlock)block;

- (void)clearMemoryCache;
- (void)deleteAllCacheFiles;

@end