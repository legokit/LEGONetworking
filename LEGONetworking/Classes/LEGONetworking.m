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

+ (void)setTokenAndHttps:(AFHTTPSessionManager *)manager {
    //设置登录用户token
    [manager.requestSerializer setValue:[LEGOTokenManager sharedManager].token forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"platform"];
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
                               params:params
                          requestType:kLEGORequestTypeJSON
                         responseType:responseType
                             progress:progress
                              success:success
                                fail:fail];
}

+ (LEGOURLSessionTask *)requestWithUrl:(NSString *)url
                             httpMedth:(NSUInteger)httpMethod
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
    [self setTokenAndHttps:manager];
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
            [self successResponse:responseObject success:success fail:fail];
            [[self allTasks] removeObject:task];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:url
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error fail:fail];
            if ([self isDebug]) {
                [self logWithFailError:error url:url params:params];
            }
        }];
    } else if (2 == httpMethod) {
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject success:success fail:fail];
            [[self allTasks] removeObject:task];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:url
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            [self handleCallbackWithError:error fail:fail];
            if ([self isDebug]) {
                [self logWithFailError:error url:url params:params];
            }
        }];
    }
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

#pragma mark - 上传与下载
+ (LEGOURLSessionTask *)uploadFileWithUrl:(NSString *)url
                            uploadingFile:(NSString *)uploadingFile
                                 progress:(LEGOUploadProgress)progress
                                  success:(LEGOResponseSuccess)success
                                     fail:(LEGOResponseFailure)fail {
    if (![NSURL URLWithString:uploadingFile]) {
        LEGONetWorkingLog(@"uploadingFile无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    
    NSURL *uploadURL = [NSURL URLWithString:url];
    if (!uploadURL) {
        LEGONetWorkingLog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，请尝试Encode URL");
        return nil;
    }
    AFHTTPSessionManager *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];
    LEGOURLSessionTask *session = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        [self successResponse:responseObject success:success fail:fail];
        if (error) {
            [self handleCallbackWithError:error fail:fail];
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }
    }];
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

+ (LEGOURLSessionTask *)uploadWithImage:(UIImage *)image
                                    url:(NSString *)url
                               filename:(NSString *)filename
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                             parameters:(NSDictionary *)parameters
                               progress:(LEGOUploadProgress)progress
                                success:(LEGOResponseSuccess)success
                                   fail:(LEGOResponseFailure)fail {
    if (![NSURL URLWithString:url]) {
        LEGONetWorkingLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    AFHTTPSessionManager *manager = [self manager];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    LEGOURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allTasks] removeObject:task];
        [self successResponse:responseObject success:success fail:fail];
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:url
                                  params:parameters];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        [self handleCallbackWithError:error fail:fail];
        if ([self isDebug]) {
            [self logWithFailError:error url:url params:nil];
        }
    }];
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

+ (LEGOURLSessionTask *)downloadWithUrl:(NSString *)url
                             saveToPath:(NSString *)saveToPath
                               progress:(LEGODownloadProgress)progressBlock
                                success:(LEGOResponseSuccess)success
                                failure:(LEGOResponseFailure)failure {
    if ([NSURL URLWithString:url] == nil) {
        LEGONetWorkingLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return nil;
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self manager];
    LEGOURLSessionTask *session = nil;
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        if (error == nil) {
            if (success) {
                [self successResponse:nil success:success fail:failure];
            }
            if ([self isDebug]) {
                LEGONetWorkingLog(@"Download success for url %@", url);
            }
        } else {
            [self handleCallbackWithError:error fail:failure];
            if ([self isDebug]) {
                LEGONetWorkingLog(@"Download fail for url %@, reason : %@",url,[error description]);
            }
        }
    }];
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
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
+ (void)successResponse:(id)responseData success:(LEGOResponseSuccess)success fail:(LEGOResponseFailure)fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    id data = [self tryToParseData:responseData];
    LEGOResponse *response = [[LEGOResponse alloc] init];
    response.data = data;
    if (success) {
        success(response);
    }
}

+ (void)handleCallbackWithError:(NSError *)error fail:(LEGOResponseFailure)fail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    LEGOResponse *response = [[LEGOResponse alloc] init];
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

#pragma mark - log 信息
+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    LEGONetWorkingLog(@"\nrequest success, \nURL: %@\n params:%@\n response:%@\n\n",[self generateGETAbsoluteURL:url params:params],params,[self tryToParseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params {
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    if ([error code] == NSURLErrorCancelled) {
        LEGONetWorkingLog(@"\nrequest was canceled mannully, \nURL: %@ %@%@\n\n",[self generateGETAbsoluteURL:url params:params],format,params);
    } else {
        LEGONetWorkingLog(@"\nrequest error, \nURL: %@ %@%@\n errorInfos:%@\n\n",[self generateGETAbsoluteURL:url params:params],format,params,[error localizedDescription]);
    }
}

+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
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


