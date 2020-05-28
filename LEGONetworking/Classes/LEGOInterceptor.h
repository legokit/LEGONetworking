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

@property (nonatomic, copy) BOOL (^sucessInterceptor)(NSData *data, LEGOResponse *response, NSString *url, NSDictionary *httpsHead, NSDictionary *params, LEGOHttpMethodType httpMethod);
@property (nonatomic, copy) void (^failInterceptor)(NSData *data, LEGOResponse *response, NSString *url, NSDictionary *httpsHead, NSDictionary *params, LEGOHttpMethodType httpMethod);

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
