//
//  LGViewController.m
//  LEGONetworking
//
//  Created by 564008993@qq.com on 05/29/2019.
//  Copyright (c) 2019 564008993@qq.com. All rights reserved.
//

#import "LGViewController.h"
#import <LEGONetworking/LEGONetworking.h>

@interface LGViewController ()

@end

@implementation LGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GET 请求 API
    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
    NSDictionary *dic = @{@"location":@"广州",
                          @"output":@"json",
                          @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
    [LEGONetworking getWithUrl:url params:dic success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {
        
    }];
    
    // GET 请求 API
//    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
//    NSDictionary *dic = @{@"location":@"广州",
//                          @"output":@"json",
//                          @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
//    [LEGONetworking getWithUrl:url params:dic progress:^(int64_t bytesRead, int64_t totalBytesRead) {
//        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
//    } success:^(LEGOResponse *response) {
//
//    } fail:^(LEGOResponse *response) {
//
//    }];

    
//    // POST API
//    NSString *url = @"http://data.zz.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
//    NSDictionary *dic = @{@"urls": @"http://www.henishuo.com/git-use-inwork/",
//                          @"goal" : @"site",
//                          @"total" : @(123)};
//    [LEGONetworking postWithUrl:url params:dic success:^(LEGOResponse *response) {
//
//    } fail:^(LEGOResponse *response) {
//
//    }];
//
//    // POST API
//    NSString *url = @"http://data.zz.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
//    NSDictionary *dic = @{@"urls": @"http://www.henishuo.com/git-use-inwork/",
//                          @"goal" : @"site",
//                          @"total" : @(123)};
//    [LEGONetworking postWithUrl:url params:dic progress:^(int64_t bytesRead, int64_t totalBytesRead) {
//        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
//    } success:^(LEGOResponse *response) {
//
//    } fail:^(LEGOResponse *response) {
//
//    }];

//
//    // DownLoad API
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/b.zip"];
//    [LEGONetworking downloadWithUrl:@"http://wiki.lbsyun.baidu.com/cms/iossdk/sdk/BaiduMap_IOSSDK_v2.10.2_All.zip" saveToPath:path progress:^(int64_t bytesRead, int64_t totalBytesRead) {
//        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
//    } success:^(id response) {
//
//    } failure:^(LEGOResponse *response) {
//
//    }];
//    
//    // Upload API
//    NSString *url = @"http://wiki.lbsyun.baidu.com/cms/iossdk/sdk/BaiduMap_IOSSDK_v2.10.2_All.zip";
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/b.zip"];
//    [LEGONetworking uploadFileWithUrl:url uploadingFile:path progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
//        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
//    } success:^(LEGOResponse *response) {
//        
//    } fail:^(LEGOResponse *response) {
//        
//    }];

//    LEGONetworkStatus networkStatus = [LEGONetworking getCurrNetworkStatus];
//    
//    typedef NS_ENUM(NSInteger, LEGONetworkStatus) {
//        kLEGONetworkStatusUnknown = -1,    // 未知网络
//        kLEGONetworkStatusNotConnection = 0,    // 网络无连接
//        kLEGONetworkStatusReachableViaWWAN = 1,    // 2，3，4G网络
//        kLEGONetworkStatusReachableViaWiFi = 2    // WIFI网络
//    };
    
    // 设置超时时间
    [LEGONetworking setTimeout:60];
    
    // 设置最大并发数
    [LEGONetworking setMaxConnectOperationCount:3];
    
    // 取消某个请求
    [LEGONetworking cancelRequestWithURL:@"http://api.map.baidu.com/telematics/v3/weather"];
    // 取消全部请求
    [LEGONetworking cancelAllRequest];

    //  NSLog(@"%@", task);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
