//
//  LEGONetworking.m
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/5/29.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import "LEGONetworking.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NSString+LGMD5.h"
#import "LEGOInterceptor.h"

static LEGONetworkStatus leogNetworkStatus = kLEGONetworkStatusUnknown;
static LEGORequestType  legoRequestType  = kLEGORequestTypeJSON;
static LEGOResponseType legoResponseType = kLEGOResponseTypeData;
static BOOL legoShouldAutoEncode = NO;
static NSMutableArray *legoRequestTasks;
static NSUInteger legoMaxConnectOperationCount = 3;
static NSTimeInterval legoTimeout = 60.0f;
static AFHTTPSessionManager *legoHttpSessionManager = nil;
static NSDictionary *legoHttpHeaders = nil;

@implementation LEGONetworking

+ (void)startMonitorNetworkStatus {
    [self addObserverNetwork];
}

#pragma mark -再次发起请求
+ (void)goon {
    if ([self allTasks] && [self allTasks].count) {
        LEGOURLSessionTask *session = [self allTasks].lastObject;
        [session resume];
    }
}

+ (NSMutableArray <LEGOURLSessionTask *> *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (legoRequestTasks == nil) {
            legoRequestTasks = [[NSMutableArray <LEGOURLSessionTask *> alloc] init];
        }
    });
    return legoRequestTasks;
}

#pragma mark -网络状态监听
+ (LEGONetworkStatus)getCurrNetworkStatus {
    return leogNetworkStatus;
}

+ (void)addObserverNetwork {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable){
            leogNetworkStatus = kLEGONetworkStatusNotConnection;
        } else if (status == AFNetworkReachabilityStatusUnknown){
            leogNetworkStatus = kLEGONetworkStatusUnknown;
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            leogNetworkStatus = kLEGONetworkStatusReachableViaWWAN;
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            leogNetworkStatus = kLEGONetworkStatusReachableViaWiFi;
        }
    }];
}

#pragma mark -配置公共参数
+ (void)setTimeout:(NSTimeInterval)timeout {
    legoTimeout = timeout;
}

+ (void)setMaxConnectOperationCount:(NSUInteger)maxConnectOperationCount {
    legoMaxConnectOperationCount = maxConnectOperationCount;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    legoHttpHeaders = httpHeaders;
}

+ (NSDictionary *)getHttpHeaders
{
    return legoHttpHeaders;
}

+ (void)configRequestType:(LEGORequestType)requestType
             responseType:(LEGOResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    legoRequestType = requestType;
    legoResponseType = responseType;
    legoShouldAutoEncode = shouldAutoEncode;
}

#pragma mark -get、post 请求
+ (AFHTTPSessionManager *)manager {
    @synchronized (self) {
        if (!legoHttpSessionManager) {
            static AFHTTPSessionManager *manager;
            if (manager == nil) {
                manager = [AFHTTPSessionManager manager];
            }
            manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*"]];
            manager.requestSerializer.timeoutInterval = legoTimeout;
            manager.operationQueue.maxConcurrentOperationCount = legoMaxConnectOperationCount;  // 请求允许的最大并发数
            legoHttpSessionManager = manager;
        }
    }
    return legoHttpSessionManager;
}

+ (void)setDefaultHttpsHeader:(AFHTTPSessionManager *)manager {
    if (legoHttpHeaders && [legoHttpHeaders isKindOfClass:[NSDictionary class]]) {
        [legoHttpHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    [manager.requestSerializer setValue:[LEGOTokenManager sharedManager].token forHTTPHeaderField:[LEGOTokenManager sharedManager].httpHeadKey];
}

+ (BOOL)shouldEncode {
    return legoShouldAutoEncode;
}

+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail {
    return [self.class getWithUrl:url
                     params:params
                   progress:nil
                    success:success
                       fail:fail];
}

+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                          progress:(LEGODownloadProgress)progress
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail {
    return [self.class getWithUrl:url params:params progress:progress responseType:kLEGOResponseTypeData success:success fail:fail];
}

+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                          progress:(LEGODownloadProgress)progress
                      responseType:(LEGOResponseType)responseType
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail {
    return [self.class requestWithUrl:url
                            httpMedth:1
                          httpsHeader:nil
                         params:params
                    requestType:kLEGORequestTypeJSON
                   responseType:responseType
                       progress:progress
                        success:success
                           fail:fail];
}

+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail {
    return [self.class postWithUrl:url
                      params:params
                    progress:nil
                     success:success
                        fail:fail];
}

+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                           progress:(LEGODownloadProgress)progress
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail {
    return [self.class postWithUrl:url params:params progress:progress responseType:kLEGOResponseTypeData success:success fail:fail];
}

+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                           progress:(LEGODownloadProgress)progress
                       responseType:(LEGOResponseType)responseType
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail {
    return [self.class requestWithUrl:url
                            httpMedth:2
                          httpsHeader:nil
                               params:params
                          requestType:kLEGORequestTypeJSON
                         responseType:responseType
                             progress:progress
                              success:success
                                fail:fail];
}

+ (LEGOURLSessionTask *)requestWithUrl:(NSString *)url
                             httpMedth:(LEGOHttpMethodType)httpMethod
                           httpsHeader:(NSDictionary *)httpsHeader
                                params:(NSDictionary *)params
                           requestType:(LEGORequestType)requestType
                          responseType:(LEGOResponseType)responseType
                              progress:(LEGODownloadProgress)progress
                               success:(LEGOResponseSuccess)success
                                  fail:(LEGOResponseFailure)fail {
    if ([self.class shouldEncode]) {
        url = [self encodeUrl:url];
    }
    if (![NSURL URLWithString:url]) {
        NSLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    AFHTTPSessionManager *manager = [self manager];
    switch (requestType) {
        case kLEGORequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case kLEGORequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    switch (responseType) {
           case kLEGOResponseTypeJSON: {
               manager.responseSerializer = [AFJSONResponseSerializer serializer];
               break;
           }
           case kLEGOResponseTypeXML: {
               manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
               break;
           }
           case kLEGOResponseTypeData: {
               manager.responseSerializer = [AFHTTPResponseSerializer serializer];
               break;
           }
           default: {
               break;
           }
    }
    if (httpsHeader && [httpsHeader isKindOfClass:[NSDictionary class]]) {
        [httpsHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    else {
        [self.class setDefaultHttpsHeader:manager];
    }

    LEGOURLSessionTask *session = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    if (LEGOHttpMethodTypeGet == httpMethod) {
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [[self allTasks] removeObject:task];
            [self successResponse:responseObject manager:manager task:task success:success fail:fail];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error task:task url:url params:params httpMethod:httpMethod fail:fail];
        }];
    } else if (LEGOHttpMethodTypePost == httpMethod) {
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [[self allTasks] removeObject:task];
            [self successResponse:responseObject manager:manager task:task success:success fail:fail];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error task:task url:url params:params httpMethod:httpMethod fail:fail];
        }];
    }
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

/// data 上传
/// @param dataArray LEGOUploadData array
/// @param params NSDictionary
/// @param httpMethod @"get" / @"post"
/// @param progress NSProgress
/// @param responseType LEGOResponseType

+ (LEGOURLSessionTask *)uploadWithUrl:(NSString *)url
                            dataArray:(NSArray <LEGOUploadData *> *)dataArray
                          httpsHeader:(NSDictionary *)httpsHeader
                               params:(NSDictionary *)params
                           httpMethod:(NSString *)httpMethod
                             progress:(void (^)(NSProgress *uploadProgress))progress
                         responseType:(LEGOResponseType)responseType
                              success:(LEGOResponseSuccess)success
                                 fail:(LEGOResponseFailure)fail;
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    switch (responseType) {
           case kLEGOResponseTypeJSON: {
               manager.responseSerializer = [AFJSONResponseSerializer serializer];
               break;
           }
           case kLEGOResponseTypeXML: {
               manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
               break;
           }
           case kLEGOResponseTypeData: {
               manager.responseSerializer = [AFHTTPResponseSerializer serializer];
               break;
           }
           default: {
               break;
           }
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:httpMethod URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (dataArray && dataArray.count) {
            [dataArray enumerateObjectsUsingBlock:^(LEGOUploadData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [formData appendPartWithFileData:obj.data name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
            }];
        }
    } error:nil];
    [httpsHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    __block NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self.class successResponse:responseObject manager:nil task:task success:success fail:fail];
                [[self allTasks] removeObject:task];
            }
            else {
                [[self allTasks] removeObject:task];
                [self handleCallbackWithError:error task:task url:url params:params httpMethod:(int)httpMethod fail:fail];
            }
        });
    }];
    [task resume];
    if (task) {
        [[self allTasks] addObject:task];
    }
    return task;
}

+ (NSString *)encodeUrl:(NSString *)url {
    return [self LEGO_URLEncode:url];
}

+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            return response;
        }
        else {
            return responseData;
        }
    } else {
        return responseData;
    }
}

#pragma mark - 请求回调成功、失败
+ (void)successResponse:(id)responseData manager:(AFHTTPSessionManager *)manager task:(NSURLSessionDataTask *)task success:(LEGOResponseSuccess)success fail:(LEGOResponseFailure)fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    id data = [self tryToParseData:responseData];
    LEGOResponse *response = [[LEGOResponse alloc] init];
    response.data = data;
    response.task = task;

    NSURLResponse *urlResponse = task.response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
    response.statusCode = httpResponse.statusCode;
    if ([LEGOInterceptor sharedManager].sucessInterceptor) {
        BOOL isPass = [LEGOInterceptor sharedManager].sucessInterceptor(responseData, response);
        if (!isPass) {
            if (fail) {
                response.code = LBRespondStatusCodeInterceptor;
                fail(response);
            }
            return;
        }
    }
    if (success) {
        success(response);
    }
}

+ (void)handleCallbackWithError:(NSError *)error task:(NSURLSessionDataTask *)task url:(NSString *)url params:(NSDictionary *)params httpMethod:(LEGOHttpMethodType)httpMethod fail:(LEGOResponseFailure)fail {
    NSData *data = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    LEGOResponse *response = [[LEGOResponse alloc] init];
    response.task = task;
    if ([error code] == NSURLErrorCancelled) {
        // 取消
        response.code = LBRespondStatusCodeFailCancel;
        response.error = error;
    }
    else if ([error code] == NSURLErrorTimedOut) {
        // 超时
        response.code = LBRespondStatusCodeFailTimedOut;
        response.error = error;
    }
    else if ([error code] == NSURLErrorNotConnectedToInternet) {
        // 丢失连接、网络为连接
        response.code = LBRespondStatusCodeFailLoseConnection;
        response.error = error;
    }
    else {
        // 未知错误，请稍后重试
        response.code = LBRespondStatusCodeFailUnknown;
        response.error = error;
    }
    response.message = message;
    NSURLResponse *urlResponse = task.response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
    response.statusCode = httpResponse.statusCode;
    
    if ([LEGOInterceptor sharedManager].failInterceptor) {
        [LEGOInterceptor sharedManager].failInterceptor(data, response, url, params, httpMethod);
    }
    if (fail) {
        fail(response);
    }
}

#pragma mark -取消请求
+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(LEGOURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[LEGOURLSessionTask class]]) {
                [task cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    };
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(LEGOURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[LEGOURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

+ (NSString *)LEGO_URLEncode:(NSString *)url {
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end


@implementation LEGOResponse

@end

@implementation LEGOUploadData

@end


