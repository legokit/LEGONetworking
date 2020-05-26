//
//  LEGOInterceptor.h
//  AFNetworking
//
//  Created by 杨庆人 on 2020/5/26.
//

#import <Foundation/Foundation.h>
#import "LEGONetworking.h"
NS_ASSUME_NONNULL_BEGIN

@interface LEGOInterceptor : NSObject

@property (nonatomic, strong) BOOL (^interceptor)(NSData *data, LEGOResponse *response);

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
