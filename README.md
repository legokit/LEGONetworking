# LEGONetworking

[![CI Status](https://img.shields.io/travis/564008993@qq.com/LEGONetworking.svg?style=flat)](https://travis-ci.org/564008993@qq.com/LEGONetworking)
[![Version](https://img.shields.io/cocoapods/v/LEGONetworking.svg?style=flat)](https://cocoapods.org/pods/LEGONetworking)
[![License](https://img.shields.io/cocoapods/l/LEGONetworking.svg?style=flat)](https://cocoapods.org/pods/LEGONetworking)
[![Platform](https://img.shields.io/cocoapods/p/LEGONetworking.svg?style=flat)](https://cocoapods.org/pods/LEGONetworking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LEGONetworking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

## Usage

```
    // GET API
    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
    NSDictionary *dic = @{@"location":@"广州",
                          @"output":@"json",
                          @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
    [LEGONetworking getWithUrl:url params:dic success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {
        
    }];
    
    // GET API 请求进度
    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
    NSDictionary *dic = @{@"location":@"广州",
                          @"output":@"json",
                          @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
    [LEGONetworking getWithUrl:url params:dic progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
    } success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {

    }];
    
    // POST API
    NSString *url = @"http://data.zz.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
    NSDictionary *dic = @{@"urls": @"http://www.henishuo.com/git-use-inwork/",
                          @"goal" : @"site",
                          @"total" : @(123)};
    [LEGONetworking postWithUrl:url params:dic success:^(LEGOResponse *response) {

    } fail:^(LEGOResponse *response) {

    }];
    
    // POST API 请求进度
    NSString *url = @"http://data.zz.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
    NSDictionary *dic = @{@"urls": @"http://www.henishuo.com/git-use-inwork/",
                          @"goal" : @"site",
                          @"total" : @(123)};
    [LEGONetworking postWithUrl:url params:dic progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
    } success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {
        
    }];
    
    // DownLoad API
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/b.zip"];
    [LEGONetworking downloadWithUrl:@"http://wiki.lbsyun.baidu.com/cms/iossdk/sdk/BaiduMap_IOSSDK_v2.10.2_All.zip" saveToPath:path progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
    } success:^(id response) {

    } failure:^(LEGOResponse *response) {

    }];
    
    // Upload API
    NSString *url = @"http://wiki.lbsyun.baidu.com/cms/iossdk/sdk/BaiduMap_IOSSDK_v2.10.2_All.zip";
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/b.zip"];
    [LEGONetworking uploadFileWithUrl:url uploadingFile:path progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        NSLog(@"progress: %f, curr: %lld, total: %lld",(bytesRead * 1.0) / totalBytesRead,bytesRead,totalBytesRead);
    } success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {
        
    }];
```

## other

```
    // 获取当前网络状态
    LEGONetworkStatus networkStatus = [LEGONetworking getCurrNetworkStatus];
    typedef NS_ENUM(NSInteger, LEGONetworkStatus) {
        kLEGONetworkStatusUnknown = -1,    // 未知网络
        kLEGONetworkStatusNotConnection = 0,    // 网络无连接
        kLEGONetworkStatusReachableViaWWAN = 1,    // 2，3，4G网络
        kLEGONetworkStatusReachableViaWiFi = 2    // WIFI网络
    };
    
    // 设置超时时间
    [LEGONetworking setTimeout:60];
    
    // 设置最大并发数
    [LEGONetworking setMaxConnectOperationCount:3];
    
    // 取消某个请求
    [LEGONetworking cancelRequestWithURL:@"http://api.map.baidu.com/telematics/v3/weather"];
    
    // 取消全部请求
    [LEGONetworking cancelAllRequest];
    
```

## about token and header

```
    //设置登录用户token
    [manager.requestSerializer setValue:[LEGOTokenManager sharedManager].token forHTTPHeaderField:@"x-token"];
    //设置当前客户端类型
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"x-client"];
    //设置当前版本
    [manager.requestSerializer setValue:[NSString stringWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"x-version"];
    //设置网络类型
    [manager.requestSerializer setValue:[@([self.class getCurrNetworkStatus]) stringValue] forHTTPHeaderField:@"x-nettype"];
    //设置设备信息
    [manager.requestSerializer setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forHTTPHeaderField:@"x-device"];
    //设置渠道
    [manager.requestSerializer setValue:@"App Store" forHTTPHeaderField:@"x-channel"];
```

```ruby
pod 'LEGONetworking'
```



## Author

564008993@qq.com, 564008993@qq.com

## License

LEGONetworking is available under the MIT license. See the LICENSE file for more info.
