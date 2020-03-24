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

#ifdef DEBUG
#define LEGONetWorkingLog(s, ... ) NSLog( @"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define LEGONetWorkingLog(s, ... )
#endif

NSString *const kNoficationKeyLoginInvalid = @"kNoficationKeyLoginInvalid";  //登录失效
NSString *const kNoficationKeyLoginError = @"kNoficationKeyLoginError";  //登录异常

static LEGONetworkStatus leogNetworkStatus = kLEGONetworkStatusUnknown;
static LEGOResponseType legoResponseType = kLEGOResponseTypeJSON;
static LEGORequestType  legoRequestType  = kLEGORequestTypeJSON;
static BOOL legoEnableDebug = NO;
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
+ (void)enableInterfaceDebug:(BOOL)isDebug {
    legoEnableDebug = isDebug;
}

+ (BOOL)isDebug {
    return legoEnableDebug;
}

+ (void)setTimeout:(NSTimeInterval)timeout {
    legoTimeout = timeout;
}

+ (void)setMaxConnectOperationCount:(NSUInteger)maxConnectOperationCount {
    legoMaxConnectOperationCount = maxConnectOperationCount;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    legoHttpHeaders = httpHeaders;
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
    return [self.class getWithUrl:url params:params progress:progress responseType:kLEGOResponseTypeJSON success:success fail:fail];
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
    return [self.class postWithUrl:url params:params progress:progress responseType:kLEGOResponseTypeJSON success:success fail:fail];
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
                             httpMedth:(NSUInteger)httpMethod
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
        LEGONetWorkingLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
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
    if (1 == httpMethod) {
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject task:task success:success fail:fail];
            [[self allTasks] removeObject:task];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:url
                                      params:params
                                  httpMethod:httpMethod];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error task:task fail:fail];
            if ([self isDebug]) {
                [self logWithFailError:error url:url params:params httpMethod:httpMethod];
            }
        }];
    } else if (2 == httpMethod) {
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject task:task success:success fail:fail];
            [[self allTasks] removeObject:task];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:url
                                      params:params
                                  httpMethod:httpMethod];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"token=%@",[LEGOTokenManager sharedManager].token);
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error task:task fail:fail];
            if ([self isDebug]) {
                [self logWithFailError:error url:url params:params httpMethod:httpMethod];
            }
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
    [request setValue:[LEGOTokenManager sharedManager].token forHTTPHeaderField:@"token"];
    [request setValue:@"1" forHTTPHeaderField:@"platform"];
    [request setValue:[UIDevice currentDevice].identifierForVendor.UUIDString forHTTPHeaderField:@"device"];
    __block NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self.class successResponse:responseObject task:task success:success fail:fail];
                [[self allTasks] removeObject:task];
                if ([self isDebug]) {
                    NSInteger httpMethodInt = [httpMethod isEqualToString:@"get"] ? 1 : 2;
                    [self logWithSuccessResponse:responseObject
                                             url:url
                                          params:params
                                      httpMethod:httpMethodInt];
                }
            }
            else {
                [[self allTasks] removeObject:task];
                [self handleCallbackWithError:error task:task fail:fail];
                if ([self isDebug]) {
                    NSInteger httpMethodInt = [httpMethod isEqualToString:@"get"] ? 1 : 2;
                    [self logWithFailError:error url:url params:params httpMethod:httpMethodInt];
                }
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
+ (void)successResponse:(id)responseData task:(NSURLSessionDataTask *)task success:(LEGOResponseSuccess)success fail:(LEGOResponseFailure)fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    id data = [self tryToParseData:responseData];
    LEGOResponse *response = [[LEGOResponse alloc] init];
    response.data = data;
    response.task = task;
    
    if (success) {
        success(response);
    }
}

+ (void)handleCallbackWithError:(NSError *)error task:(NSURLSessionDataTask *)task fail:(LEGOResponseFailure)fail {
    NSString *message = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
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
    NSURLResponse *urlResponse = task.response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
    if (httpResponse.statusCode == 401) {
        [LEGOTokenManager clearToken];
        if (fail) {
            fail(response);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoficationKeyLoginInvalid object:nil];
        
    }
    else if (httpResponse.statusCode == 400) {
        [LEGOTokenManager clearToken];
        if (fail) {
            fail(response);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoficationKeyLoginError object:nil];
    }
    else {
        if (fail) {
            response.message = message;
            fail(response);
        }
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

#pragma mark - log 信息
+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params httpMethod:(NSInteger)httpMethod  {
    NSString *requestType = httpMethod == 1 ? @"get" : @"post";
    LEGONetWorkingLog(@"\nrequest success, \nURL:%@ \n%@ \n params:%@\n response:%@\ntoken=%@\ndevice=%@",[self generateGETAbsoluteURL:url params:params httpMethod:httpMethod],requestType,params,[self tryToParseData:response],[LEGOTokenManager sharedManager].token,[UIDevice currentDevice].identifierForVendor.UUIDString);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params httpMethod:(NSInteger)httpMethod {
    NSString *message = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSString *requestType = httpMethod == 1 ? @"get" : @"post";
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    if ([error code] == NSURLErrorCancelled) {
        LEGONetWorkingLog(@"\nrequest was canceled mannully, \nURL: %@ \n%@\n %@%@\ntoken:%@\nmessage:%@\ndevice=%@",[self generateGETAbsoluteURL:url params:params httpMethod:httpMethod],requestType,format,params,[LEGOTokenManager sharedManager].token,message,[UIDevice currentDevice].identifierForVendor.UUIDString);
    } else {
        LEGONetWorkingLog(@"\nrequest error, \nURL: %@ \n%@\n %@%@\n errorInfos:%@\ntoken:%@\nmessager:%@\ndevice=%@",[self generateGETAbsoluteURL:url params:params httpMethod:httpMethod],requestType,format,params,[error localizedDescription],[LEGOTokenManager sharedManager].token,message,[UIDevice currentDevice].identifierForVendor.UUIDString);
    }
}

+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params httpMethod:(NSInteger)httpMethod {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0 || httpMethod == 2) {
        return url;
    }
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    return url.length == 0 ? queries : url;
}

@end


@implementation LEGOResponse

@end

@implementation LEGOUploadData

@end


