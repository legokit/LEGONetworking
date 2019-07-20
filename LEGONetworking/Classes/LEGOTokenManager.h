//
//  LEGOTokenManager.h
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/7/15.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEGOTokenManager : NSObject
@property (nonatomic, copy, readonly) NSString *token;

+ (instancetype)sharedManager;

+ (void)saveToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
