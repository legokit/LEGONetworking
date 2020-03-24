//
//  LEGOTokenManager.m
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/7/15.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import "LEGOTokenManager.h"

NSString *const kUserDefaultsKeyTokenManagerToken = @"kUserDefaultsKeyTokenManagerToken";
NSString *const kUserDefaultsKeyTokenManagerHttpHeadKey = @"kUserDefaultsKeyTokenManagerHttpHeadKey";

@interface LEGOTokenManager ()
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *httpHeadKey;

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

- (NSString *)httpHeadKey {
    if (!_httpHeadKey) {
        NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsKeyTokenManagerHttpHeadKey];
        if (key && key.length) {
            _httpHeadKey = key;
        }
        else {
            _httpHeadKey = @"token";
        }
    }
    return _httpHeadKey;
}

+ (void)saveToken:(NSString *)token {
    [LEGOTokenManager sharedManager].token = token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kUserDefaultsKeyTokenManagerToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveToken:(NSString *)token httpHeadKey:(NSString *)httpHeadKey {
    [self.class saveToken:token];
    [LEGOTokenManager sharedManager].httpHeadKey = httpHeadKey;
    [[NSUserDefaults standardUserDefaults] setObject:httpHeadKey forKey:kUserDefaultsKeyTokenManagerHttpHeadKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearToken {
    [LEGOTokenManager sharedManager].token = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyTokenManagerToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
