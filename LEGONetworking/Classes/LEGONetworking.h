//
//  LEGONetworking.h
//  LEGONetworking_Example
//
//  Created by 杨庆人 on 2019/5/29.
//  Copyright © 2019年 564008993@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEGOTokenManager.h"
@class LEGOResponse,LEGOUploadData;

typedef NSURLSessionTask LEGOURLSessionTask;
typedef void (^LEGOResponseSuccess) (LEGOResponse *response);
typedef void (^LEGOResponseFailure) (LEGOResponse *response);

typedef NS_ENUM(NSInteger,LEGORespondStatusCode) {
    // 响应失败
    LBRespondStatusCodeFailUnknown = 2000,    // 未知错误，请稍后重试
    LBRespondStatusCodeFailLoseConnection = 2001,    // 网络未连接
    LEGORespondStatusCodeNeedLogin = 2002,    // 接口需要登录，请登录后重试
    LBRespondStatusCodeFailCancel = 2003,    // 请求取消
    LBRespondStatusCodeFailTimedOut = 2004,    // 请求超时
    LBRespondStatusCodeUnReadable = 2005,  // 消息不可读
    LBRespondStatusCodeInterceptor = 2006  // 本地拦截
};

typedef NS_ENUM(NSInteger, LEGONetworkStatus) {
    kLEGONetworkStatusUnknown = -1,    // 未知网络
    kLEGONetworkStatusNotConnection = 0,    // 网络无连接
    kLEGONetworkStatusReachableViaWWAN = 1,    // 2，3，4G网络
    kLEGONetworkStatusReachableViaWiFi = 2    // WIFI网络
};

typedef NS_ENUM(NSUInteger, LEGORequestType) {
    kLEGORequestTypeJSON = 1,    // json 默认
    kLEGORequestTypePlainText = 2    // text/html
};

typedef NS_ENUM(NSUInteger, LEGOResponseType) {
    kLEGOResponseTypeJSON = 1,    // json 默认
    kLEGOResponseTypeXML  = 2,    // XML
    kLEGOResponseTypeData = 3    // data
};

typedef NS_ENUM(NSUInteger, LEGOHttpMethodType) {
    LEGOHttpMethodTypeGet = 1,    // get
    LEGOHttpMethodTypePost  = 2,    // post
};

/** 下载进度，已下载的大小，文件总大小 */
typedef void (^LEGODownloadProgress)(int64_t bytesRead, int64_t totalBytesRead);

/** 上传进度，已上传的大小，总上传大小 */
typedef void (^LEGOUploadProgress)(int64_t bytesWritten, int64_t totalBytesWritten);

/**
 基于AFNetworking的网络层封装类.
 */
@interface LEGONetworking : NSObject

/**
 开始监听网络事件
 */
+ (void)startMonitorNetworkStatus;

/**
 再次发起上次的请求，用于请求的接口需要登录，但是请求过后发现token已经过期等情况
 */
+ (void)goon;

/**
 获取当前网络状态
 
 @return LEGONetworkStatus
 */
+ (LEGONetworkStatus)getCurrNetworkStatus;

/**
 设置请求超时时间，默认为60秒
 
 @param timeout 超时时间
 */
+ (void)setTimeout:(NSTimeInterval)timeout;

/**
 设置请求最大并发数，默认为3个，设置过多容易引发问题
 
 @param maxConnectOperationCount 请求最大并发数
 */
+ (void)setMaxConnectOperationCount:(NSUInteger)maxConnectOperationCount;

/**
 配置公共的请求头，放在应用启动的时候配置就可以了
 
 @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 获取配置公共的请求头
  */
+ (NSDictionary *)getHttpHeaders;

/**
 配置请求格式，默认为JSON。如果要求传递XML或者PLIST，请在全局配置一下
 
 @param requestType 请求格式，默认为json
 @param responseType 响应格式，默认为json，
 @param shouldAutoEncode 是否自动 encode url
 */
+ (void)configRequestType:(LEGORequestType)requestType
             responseType:(LEGOResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/**
 GET请求接口
 
 @param url 完整url
 @param params 参数，将自动拼接到get请求之后
 @param success 请求成功
 @param fail 请求失败
 @return LEGOURLSessionTask
 */
+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail;

+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                          progress:(LEGODownloadProgress)progress
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail;

+ (LEGOURLSessionTask *)getWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                          progress:(LEGODownloadProgress)progress
                      responseType:(LEGOResponseType)responseType
                           success:(LEGOResponseSuccess)success
                              fail:(LEGOResponseFailure)fail;

/**
 POST请求
 
 @param url 完整url
 @param params 接口中所需的参数
 @param success 请求成功
 @param fail 请求失败
 @return LEGOURLSessionTask
 */
+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail;

+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                           progress:(LEGODownloadProgress)progress
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail;

+ (LEGOURLSessionTask *)postWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                           progress:(LEGODownloadProgress)progress
                       responseType:(LEGOResponseType)responseType
                            success:(LEGOResponseSuccess)success
                               fail:(LEGOResponseFailure)fail;


/**
通用请求

@param url 完整url
@param httpMethod  get:1, post:2
@param httpsHeader 请求头，如果为空，则取默认
@param params 接口中所需的参数
@param success 请求成功
@param fail 请求失败
@return LEGOURLSessionTask
*/
+ (LEGOURLSessionTask *)requestWithUrl:(NSString *)url
                             httpMedth:(LEGOHttpMethodType)httpMethod
                           httpsHeader:(NSDictionary *)httpsHeader
                                params:(NSDictionary *)params
                           requestType:(LEGORequestType)requestType
                          responseType:(LEGOResponseType)responseType
                              progress:(LEGODownloadProgress)progress
                               success:(LEGOResponseSuccess)success
                                  fail:(LEGOResponseFailure)fail;

+ (LEGOURLSessionTask *)requestWithUrl:(NSString *)url
                             httpMedth:(LEGOHttpMethodType)httpMethod
                           httpsHeader:(NSDictionary *)httpsHeader
                            paramsData:(NSData *)paramsData
                           requestType:(LEGORequestType)requestType
                          responseType:(LEGOResponseType)responseType
                               success:(LEGOResponseSuccess)success
                                  fail:(LEGOResponseFailure)fail;


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

/// data 下载
/// @param path 存储路径
/// @param params NSDictionary
/// @param progress NSProgress
/// @param responseType LEGOResponseType

+ (LEGOURLSessionTask *)downloadWithUrl:(NSString *)url
                                   path:(NSURL *)path
                            httpsHeader:(NSDictionary *)httpsHeader
                                 params:(NSDictionary *)params
                               progress:(void (^)(NSProgress *uploadProgress))progress
                           responseType:(LEGOResponseType)responseType
                                success:(LEGOResponseSuccess)success
                                   fail:(LEGOResponseFailure)fail;

/**
 取消某个请求。如果是要取消某个请求，最好是引用接口所返回来的LEGOURLSessionTask对象，然后调用对象的cancel方法。如果不想引用对象，这里额外提供了一种方法来实现取消某个请求
 
 @param url NSString
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 取消所有请求
 */
+ (void)cancelAllRequest;


@end

@interface LEGOResponse : NSObject
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) LEGORespondStatusCode code;

@end


@interface LEGOUploadData : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;

@end
