//
//  NSString+LGMD5.m
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/7/12.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import "NSString+LGMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LGMD5)

+ (NSString *)legoNetworking_md5:(NSString *)string {
    if (string == nil || string.length == 0) {
        return nil;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}

@end

