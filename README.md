# LEGONetworking

Network request tool, basic get and post request methods, including request progress, upload and download progress, monitoring network, setting network timeout and cancel request  网络请求工具，基础的 get、post 请求方法，包含请求进度，上传和下载的进度，监听网络、设置网络超时和取消请求

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LEGONetworking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/legokit/Specs.git'
pod 'LEGONetworking'
```

**LEGONetworking** is the photo management tool, you can get album list, photo list, save photos, delete photos, get photos by iCloud, cancel photo request  照片管理工具，可以获取相册列表、照片列表，保存照片、删除照片，通过 iCloud 获取照片，取消照片请求

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Features

- [x] Get and Post.
- [x] Upload and Download. 
- [x] request progress.  
- [x] monitoring network.  
- [x] Cancel request.  

## Requirements

- iOS 8.0+
- Xcode 10.0+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate LEGOPhotosManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/legokit/Specs.git'
pod 'LEGONetworking'
```

### Manually

If you prefer not to use any of the dependency mentioned above, you can integrate LEGOPhotosManager into your project manually. Just drag & drop the `Sources` folder to your project.


## Usage

### Get and Post.
```
    // GET API
    NSString *url = @"http://api.map.baidu.com/telematics/v3/weather";
    NSDictionary *dic = @{@"location":@"广州",
                          @"output":@"json",
                          @"ak":@"5slgyqGDENN7Sy7pw29IUvrZ"};
    [LEGONetworking getWithUrl:url params:dic success:^(LEGOResponse *response) {
        
    } fail:^(LEGOResponse *response) {
        
    }];
    
    // GET API progress
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
    
    // POST API progress
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
### monitoring network.
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
