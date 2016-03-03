//
//  EsttTransformPicUrl.m
//  CKG
//
//  Created by ZhJ on 16/3/3.
//  Copyright © 2016年 ESTT. All rights reserved.
//

#import "EsttTransformPicUrl.h"

#define BASE_HOST @"estt.com.cn"
//#define BASE_HOST @"bzsns.cn"
#define BASE_HOST_CHILDREN @[@"static",@"www",@"test",@"dev",@"fdfs"]

@implementation EsttTransformPicUrl

// 获取原生大小图片地址
+ (NSURL *)transformToOriginSize:(NSURL *)picUrl {
    
    NSString *host = [picUrl host];
    
    BOOL isOurServer = NO;
    if ([host containsString:BASE_HOST]) {
        NSMutableArray *childrenHost = [NSMutableArray arrayWithArray:BASE_HOST_CHILDREN];
        NSString *child = [host componentsSeparatedByString:@"."][0];
        isOurServer = [childrenHost containsObject:child]? YES : NO;
    }
    
    if (isOurServer) {
        NSString *fileName = [[picUrl pathComponents] lastObject];
        
        NSMutableString *newFileName = [NSMutableString stringWithString:[fileName copy]];
        NSRange range = [fileName rangeOfString:@"_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            newFileName = [NSMutableString stringWithString:[fileName componentsSeparatedByString:@"_"][0]];
        }
        
        NSMutableString *picUrlStr = [NSMutableString stringWithString:[picUrl absoluteString]];
        [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
        
        NSURL *newPicUrl = [NSURL URLWithString:picUrlStr];
        
        return newPicUrl;
    } else {
        return picUrl;
    }
}

// 获取固定大小图片地址
+ (NSURL *)transformUrl:(NSURL *)picUrl ToSize:(CGSize)confirmSize andTimes:(CGFloat) time{
    
    NSString *host = [picUrl host];
    
    BOOL isOurServer = NO;
    if ([host containsString:BASE_HOST]) {
        NSMutableArray *childrenHost = [NSMutableArray arrayWithArray:BASE_HOST_CHILDREN];
        NSString *child = [host componentsSeparatedByString:@"."][0];
        isOurServer = [childrenHost containsObject:child]? YES : NO;
    }
    
    if (isOurServer) {
        NSString *fileName = [[picUrl pathComponents] lastObject];
        
        NSMutableString *newFileName = [NSMutableString stringWithString:[fileName copy]];
        NSMutableString *picUrlStr = [NSMutableString stringWithString:[picUrl absoluteString]];
        NSURL *newPicUrl;
        NSRange range = [fileName rangeOfString:@"_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            newFileName = [NSMutableString stringWithString:[fileName componentsSeparatedByString:@"_"][0]];
            [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
            newPicUrl = [NSURL URLWithString:picUrlStr];
        }
        
        NSString *sizeStr = [NSString stringWithFormat:@"_%.fx%.f.png", confirmSize.width*time, confirmSize.height*time];
        [newFileName appendString:sizeStr];
        fileName = [[picUrl pathComponents] lastObject];
        [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
        newPicUrl = [NSURL URLWithString:picUrlStr];
        
        return newPicUrl;
    } else {
        return picUrl;
    }
}

// 获取固定宽自动高图片地址
+ (NSURL *)transformUrl:(NSURL *)picUrl ToWidth:(CGFloat)width andTimes:(CGFloat) time{
    
    NSString *host = [picUrl host];
    
    BOOL isOurServer = NO;
    if ([host containsString:BASE_HOST]) {
        NSMutableArray *childrenHost = [NSMutableArray arrayWithArray:BASE_HOST_CHILDREN];
        NSString *child = [host componentsSeparatedByString:@"."][0];
        isOurServer = [childrenHost containsObject:child]? YES : NO;
    }
    
    if (isOurServer) {
        NSString *fileName = [[picUrl pathComponents] lastObject];
        
        NSMutableString *newFileName = [NSMutableString stringWithString:[fileName copy]];
        NSMutableString *picUrlStr = [NSMutableString stringWithString:[picUrl absoluteString]];
        NSURL *newPicUrl;
        NSRange range = [fileName rangeOfString:@"_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            newFileName = [NSMutableString stringWithString:[fileName componentsSeparatedByString:@"_"][0]];
            [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
            newPicUrl = [NSURL URLWithString:picUrlStr];
        }
        
        NSString *sizeStr = [NSString stringWithFormat:@"_%.f-.jpg", width*time];
        [newFileName appendString:sizeStr];
        fileName = [[picUrl pathComponents] lastObject];
        [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
        newPicUrl = [NSURL URLWithString:picUrlStr];
        
        return newPicUrl;
    } else {
        return picUrl;
    }
}

// 获取固定高自动宽图片地址
+ (NSURL *)transformUrl:(NSURL *)picUrl ToHeight:(CGFloat)height andTimes:(CGFloat) time{
    
    NSString *host = [picUrl host];
    
    BOOL isOurServer = NO;
    if ([host containsString:BASE_HOST]) {
        NSMutableArray *childrenHost = [NSMutableArray arrayWithArray:BASE_HOST_CHILDREN];
        NSString *child = [host componentsSeparatedByString:@"."][0];
        isOurServer = [childrenHost containsObject:child]? YES : NO;
    }
    
    if (isOurServer) {
        NSString *fileName = [[picUrl pathComponents] lastObject];
        
        NSMutableString *newFileName = [NSMutableString stringWithString:[fileName copy]];
        NSMutableString *picUrlStr = [NSMutableString stringWithString:[picUrl absoluteString]];
        NSURL *newPicUrl;
        NSRange range = [fileName rangeOfString:@"_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            newFileName = [NSMutableString stringWithString:[fileName componentsSeparatedByString:@"_"][0]];
            [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
            newPicUrl = [NSURL URLWithString:picUrlStr];
        }
        
        NSString *sizeStr = [NSString stringWithFormat:@"_-%.f.jpg", height*time];
        [newFileName appendString:sizeStr];
        fileName = [[picUrl pathComponents] lastObject];
        [picUrlStr replaceCharactersInRange:[picUrlStr rangeOfString:fileName] withString:newFileName];
        newPicUrl = [NSURL URLWithString:picUrlStr];
        
        return newPicUrl;
    } else {
        return picUrl;
    }
}

/**
 * 解析URL参数的工具方法。
 */
+ (NSDictionary *)parseURLParams:(NSString *)query{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *val =[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
    }
    return params;
}

@end
