//
//  EsttTransformPicUrl.h
//  CKG
//
//  Created by ZhJ on 16/3/3.
//  Copyright © 2016年 ESTT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EsttTransformPicUrl : NSObject

/**
 * 获取原生大小图片地址
 */
+ (NSURL *)transformToOriginSize:(NSURL *)picUrl;

/**
 * 获取固定大小图片地址
 */
+ (NSURL *)transformUrl:(NSURL *)picUrl ToSize:(CGSize)confirmSize;

/**
 * 获取固定宽自动高图片地址
 */
+ (NSURL *)transformUrl:(NSURL *)picUrl ToWidth:(CGFloat)width;

/**
 * 获取固定高自动宽图片地址
 */
+ (NSURL *)transformUrl:(NSURL *)picUrl ToHeight:(CGFloat)height;

/**
 * 解析URL参数的工具方法。
 */
+ (NSDictionary *)parseURLParams:(NSString *)query;

@end
