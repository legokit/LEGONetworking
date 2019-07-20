//
//  LEGOTokenManager.m
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/7/15.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import "LEGOTokenManager.h"

NSString *const kUserDefaultsKeyTokenManagerToken = @"kUserDefaultsKeyTokenManagerToken";

@interface LEGOTokenManager ()
@property (nonatomic, copy) NSString *token;
@end

@implementation LEGOTokenManager

+ (instancetype)sharedManager {
    static __kindof LEGOTokenManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

- (NSString *)token {
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyTokenManagerToken];
    }
    return _token;
}

+ (void)saveToken:(NSString *)token {
    [LEGOTokenManager sharedManager].token = token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kUserDefaultsKeyTokenManagerToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
