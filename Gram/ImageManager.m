//
//  ImageManager.m
//  News
//
//  Created by Kenya Yoshimura on 2013/11/04.
//  Copyright (c) 2013年 Monolith Works Inc. All rights reserved.
//

#import "ImageManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import <CommonCrypto/CommonHMAC.h>

#import "NSString+MWORKS.h"

@interface ImageManager()
{
    NSFileManager *fileManager;
    NSString *cacheDirectory;
    NSString *thumbnailDirectory;
    NSCache *cache;
    NSCache *thumbnail;
    
    NSMutableArray *queue;
    ASINetworkQueue *networkQueue;
}

@end

@implementation ImageManager

+ (ImageManager *)sharedInstance
{
    static ImageManager *instance;
    if (instance == nil)
    {
        instance = [ImageManager new];
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(didReceiveMemoryWarning:)
         name:UIApplicationDidReceiveMemoryWarningNotification
         object:nil];
        
        queue = [NSMutableArray array];
        
        cache = [[NSCache alloc] init];
        thumbnail = [[NSCache alloc] init];
        cache.countLimit = 1000;
        thumbnail.countLimit = 1000;
        
        fileManager = [[NSFileManager alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheDirectory = [[paths lastObject] stringByAppendingPathComponent:@"Images"];
        thumbnailDirectory = [[paths lastObject] stringByAppendingPathComponent:@"Thumbnails"];
        
        [self createDirectories:cacheDirectory];
        [self createDirectories:thumbnailDirectory];
        
        networkQueue = [[ASINetworkQueue alloc] init];
        [networkQueue setMaxConcurrentOperationCount:1];
        [networkQueue go];
    }
    return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notif
{
    [self clearMemoryCache];
    [self clearMemoryThumbnail];
}

- (void)createDirectories:(NSString *)path
{
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists || !isDirectory)
    {
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    for (int i = 0; i < 16; i++)
    {
        for (int j = 0; j < 16; j++)
        {
            NSString *subDirectory = [NSString stringWithFormat:@"%@/%X%X", path, i, j];
            BOOL isSubDirectory = NO;
            BOOL existsSubDirectory = [fileManager fileExistsAtPath:subDirectory isDirectory:&isSubDirectory];
            if (!existsSubDirectory || !isSubDirectory)
            {
                [fileManager createDirectoryAtPath:subDirectory
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
            }
        }
    }
}

#pragma mark -

+ (NSString *)keyForURL:(NSString *)URL
{
	if ([URL length] == 0)
    {
		return nil;
	}
	const char *cStr = [URL UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (NSString *)pathForKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", cacheDirectory, [key substringToIndex:2], key];
    return path;
}

- (NSString *)thumbnailForKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", thumbnailDirectory, [key substringToIndex:2], key];
    return path;
}

#pragma mark -

+ (NSString *)getLocalURL:(NSString *)URL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [[paths lastObject] stringByAppendingPathComponent:@"Images"];
    NSString *key = [ImageManager keyForURL:URL];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", directory, [key substringToIndex:2], key];
    return path;
}

- (UIImage *)cachedImageWithURL:(NSString *)URL
{
    NSString *key = [ImageManager keyForURL:URL];
    UIImage *cachedImage = [cache objectForKey:key];
    if (cachedImage)
    {
        return cachedImage;
    }
    
    cachedImage = [UIImage imageWithContentsOfFile:[self pathForKey:key]];
    if (cachedImage)
    {
        [cache setObject:cachedImage forKey:key];
    }
    
    return cachedImage;
}

- (UIImage *)cachedThumbnailWithURL:(NSString *)URL
{
    NSString *key = [ImageManager keyForURL:URL];
    UIImage *cachedImage = [thumbnail objectForKey:key];
    if (cachedImage)
    {
        return cachedImage;
    }
    
    cachedImage = [UIImage imageWithContentsOfFile:[self thumbnailForKey:key]];
    if (cachedImage)
    {
        [thumbnail setObject:cachedImage forKey:key];
    }
    
    return cachedImage;
}

#pragma mark -

- (void)storeImage:(UIImage *)image data:(NSData *)data URL:(NSString *)URL
{
    NSString *key = [ImageManager keyForURL:URL];
    [cache setObject:image forKey:key];
    
    [data writeToFile:[self pathForKey:key] atomically:NO];
}

- (void)storeThumbnail:(UIImage *)image data:(NSData *)data URL:(NSString *)URL
{
    NSString *key = [ImageManager keyForURL:URL];
    [thumbnail setObject:image forKey:key];
    
    [data writeToFile:[self thumbnailForKey:key] atomically:NO];
}

- (void)clearMemoryCache
{
    [cache removeAllObjects];
}

- (void)clearMemoryThumbnail
{
    [thumbnail removeAllObjects];
}

- (void)deleteAllCacheFiles
{
    [cache removeAllObjects];
    
    if ([fileManager fileExistsAtPath:cacheDirectory])
    {
        if ([fileManager removeItemAtPath:cacheDirectory error:nil])
        {
            [self createDirectories:cacheDirectory];
        }
    }
    
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:cacheDirectory isDirectory:&isDirectory];
    if (!exists || !isDirectory)
    {
        [fileManager createDirectoryAtPath:cacheDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
}

- (void)deleteAllThumbnailFiles
{
    [thumbnail removeAllObjects];
    
    if ([fileManager fileExistsAtPath:thumbnailDirectory])
    {
        if ([fileManager removeItemAtPath:thumbnailDirectory error:nil])
        {
            [self createDirectories:thumbnailDirectory];
        }
    }
    
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:thumbnailDirectory isDirectory:&isDirectory];
    if (!exists || !isDirectory)
    {
        [fileManager createDirectoryAtPath:thumbnailDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
}

#pragma mark -

- (UIImage *)imageWithURL:(NSString *)URL block:(ImageCacheResultBlock)block
{
    return [self imageWithURL:URL defaultImage:nil block:block];
}

- (UIImage *)imageWithURL:(NSString *)URL defaultImage:(UIImage *)defaultImage block:(ImageCacheResultBlock)block
{
    if (!URL)
    {
        return defaultImage;
    }
    
    UIImage *cachedImage = [self cachedImageWithURL:URL];
    if (cachedImage)
    {
        return cachedImage;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URL]];
    
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            [self storeImage:image data:data URL:URL];
            block(image, URL, nil);
        }
        else
        {
            block(nil, URL, [NSError errorWithDomain:@"ImageCacheErrorDomain" code:0 userInfo:nil]);
        }
    }];
    [request setFailedBlock:^{
        block(nil, URL, request.error);
    }];
    
    [networkQueue addOperation:request];
    //[self addOperation:request];
    
    return defaultImage;
}

- (UIImage *)thumbnailWithURL:(NSString *)URL block:(ImageCacheResultBlock)block
{
    UIImage *cachedImage = [self cachedThumbnailWithURL:URL];
    if (cachedImage)
    {
        return cachedImage;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URL]];
    
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            block(image, URL, nil);
            
            NSArray *contents = @[
                @{
                    @"image":image,
                    @"data":data,
                    @"url":URL
                },
                @{
                    @"image":image,
                    @"url":URL
                }
            ];
            
            [self performSelectorInBackground:@selector(save:) withObject:contents];
            
        }
        else
        {
            block(nil, URL, [NSError errorWithDomain:@"ImageCacheErrorDomain" code:0 userInfo:nil]);
        }
    }];
    [request setFailedBlock:^{
        block(nil, URL, request.error);
    }];
    
    [networkQueue addOperation:request];
    //[self addOperation:request];
    
    return nil;
}

- (void)save:(NSArray *)contents
{
    for (NSDictionary *content in contents)
    {
        if ([content objectForKey:@"data"])
        {
            UIImage *image = [content objectForKey:@"image"];
            NSData *data = [content objectForKey:@"data"];
            NSString *url = [content objectForKey:@"url"];
            [self storeImage:image data:data URL:url];
        }
        else
        {
            UIImage *image = [content objectForKey:@"image"];
            NSString *url = [content objectForKey:@"url"];
            UIImage *resize = [self resizeImage:image size:CGSizeMake(140, 140)];
            [self storeThumbnail:resize data:UIImagePNGRepresentation(resize) URL:url];
        }
    }
}

- (void)addOperation:(ASIHTTPRequest *)request
{
    [queue addObject:request];
    
    [self proceed];
}

- (void)proceed
{
    if ([queue count] > 0)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(proceed) object:nil];
        
        if ([[networkQueue operations] count] < 1)
        {
            ASIHTTPRequest *request = [queue lastObject];
            if (request)
            {
                [networkQueue addOperation:request];
                
                [queue removeObject:request];
            }
        }
        
        [self performSelector:@selector(proceed) withObject:nil afterDelay:0.1f];
    }
    else
    {
        NSLog(@"Queue completed");
    }
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
    
    if (image.size.height > image.size.width)
    {
        [image drawInRect:CGRectMake((size.width / 2) - ((image.size.width / image.size.height) * size.width / 2), 0.0, (image.size.width / image.size.height) * size.width, size.height)];
    }
    else
        [image drawInRect:CGRectMake(0.0, (size.width / 2) - ((image.size.height / image.size.width) * size.height / 2), size.width, (image.size.height / image.size.width) * size.height)];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end