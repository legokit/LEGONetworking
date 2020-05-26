//
//  LEGOInterceptor.m
//  AFNetworking
//
//  Created by 杨庆人 on 2020/5/26.
//

#import "LEGOInterceptor.h"

@implementation LEGOInterceptor

+ (instancetype)sharedManager {
    static __kindof LEGOInterceptor *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

@end
