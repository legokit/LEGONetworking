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
    
    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
    
    NSDictionary *dic = @{@"location":@"广州",
                            @"output":@"json",
                                @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
    
    [LEGONetworking getWithUrl:url params:dic progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        NSLog(@"progress: %f, cur: %lld, total: %lld",
              (bytesRead * 1.0) / totalBytesRead,
              bytesRead,
              totalBytesRead);
    } success:^(LEGOResponse *response) {

    } fail:^(LEGOResponse *response) {

    }];

    
//    // 测试POST API：
//    NSDictionary *dic = @{ @"urls": @"http://www.henishuo.com/git-use-inwork/",
//                            @"goal" : @"site",
//                            @"total" : @(123)
//                                };
//    NSString *url = @"http://data.zz.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
//    [LEGONetworking postWithUrl:url params:dic success:^(LEGOResponse *response) {
//
//    } fail:^(LEGOResponse *response) {
//
//    }];

//
//    path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/b.zip"];
//    [LEGONetworking downloadWithUrl:@"http://wiki.lbsyun.baidu.com/cms/iossdk/sdk/BaiduMap_IOSSDK_v2.10.2_All.zip" saveToPath:path progress:^(int64_t bytesRead, int64_t totalBytesRead) {
//
//    } success:^(id response) {
//
//    } failure:^(NSError *error) {
//
//    }];
    
    //  NSLog(@"%@", task);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
