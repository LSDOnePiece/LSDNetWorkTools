//
//  LSDHTTPNetWorkTool.m
//  LSDNetWorkTools
//
//  Created by ls on 16/6/12.
//  Copyright © 2016年 szrd. All rights reserved.
//

#import "LSDHTTPNetWorkTool.h"
#import "AFNetworkActivityIndicatorManager.h"

///请求头字典
static NSDictionary *lsd_httpHeaders = nil;
///超时时间
static NSTimeInterval lsd_timeout = 0.0;
///网络状态
static BOOL _networkReachability;
@interface LSDHTTPNetWorkTool ()
{
    ///debug打印开关
    BOOL _debug;
}

///下载管理者
@property(strong,nonatomic)AFURLSessionManager *downloadManager;
///下载队列
@property(strong,nonatomic)NSOperationQueue *downloadOperationQueue;

@property(strong,nonatomic)NSURLSession *downLoadSession;

@property(strong,nonatomic)NSData *resumeData;
///下载任务
@property(strong,nonatomic)NSURLSessionDownloadTask *downloadTask;

@end


@implementation LSDHTTPNetWorkTool

static NSString *_baseUrlString = nil;

static LSDHTTPNetWorkTool *_instance = nil;

#pragma mark -- 更新更改baseUrlString
+(void)lsd_updateBaseUrlWithUrlString:(NSString *)baseUrlString
{
    _baseUrlString = baseUrlString;
}

#pragma mark -- 配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
+(void)lsd_configCommonHttpHeaders:(NSDictionary *)httpHeaders
{
    lsd_httpHeaders = httpHeaders;
}

#pragma mark -- 设置网络超时时长
+ (void)lsd_setTimeout:(NSTimeInterval)timeout
{
    lsd_timeout = timeout;
}


#pragma mark -- 单例对象
+(instancetype)sharedManager
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc]initWithBaseURL:[NSURL URLWithString:_baseUrlString]];
            
            ///设置请求头
            for (NSString *key in lsd_httpHeaders.allKeys) {
                if (lsd_httpHeaders[key] != nil) {
                    [_instance.requestSerializer setValue:lsd_httpHeaders[key] forHTTPHeaderField:key];
                }
            }
            
            _instance.responseSerializer.acceptableContentTypes =
            [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", @"application/xml", @"text/xml",@"image/*",nil];
            
            
            if (lsd_timeout) {
                _instance.requestSerializer.timeoutInterval = lsd_timeout;
            }else
            {
                _instance.requestSerializer.timeoutInterval = 15.0;
            }
            
            _instance.requestSerializer.stringEncoding = NSUTF8StringEncoding;
            
            [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        }
    });
    return _instance;
}

#pragma mark -- 是否有网络
+(BOOL)lsd_hasNetworkReachability
{
    
    return _networkReachability;
}
#pragma mark -- 检测网络状态
+(void)lsd_checkNetWorkState
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager] ;
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"无线网络");
                [LSDHTTPNetWorkTool sharedManager].networkStatus = AFNetworkReachabilityStatusReachableViaWiFi;
                _networkReachability = YES;
                
                
                break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                [LSDHTTPNetWorkTool sharedManager].networkStatus = AFNetworkReachabilityStatusReachableViaWWAN;
                _networkReachability = YES;
                
                
                break;
                case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"未连接,网络不给力!");
                [LSDHTTPNetWorkTool sharedManager].networkStatus = AFNetworkReachabilityStatusNotReachable;
                _networkReachability = NO;
                
                break;
                case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知错误");
                [LSDHTTPNetWorkTool sharedManager].networkStatus = AFNetworkReachabilityStatusUnknown;
                _networkReachability = NO;
                break;
        }
    }];
    
    [mgr startMonitoring];
    
}

#pragma mark -- 这个类加载到内存中时调用
+ (void)load{
    [self lsd_checkNetWorkState];
}

#pragma mark -- debug调试打印开关
-(void)lsd_configureDebugLogSwitch:(BOOL)debug
{
    _debug = debug;
}

#pragma mark -- 请求体格式
-(void)lsd_configRequestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
{
    _instance.requestSerializer = requestSerializer;
}
#pragma mark -- 响应体格式
-(void)lsd_configResponseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer
{
    _instance.responseSerializer = responseSerializer;
}

#pragma mark -- 从网络服务器上获取数据
-(void)lsd_loadDataFromNetWorkWithHttpRequestType:(LSDHttpRequestType)httpRequestType urlString:( NSString * _Nonnull )urlString parameters:(NSDictionary *)parameters progressBlock:(_Nullable DownloadProgressBlock)downloadProgressBlock successBlock:(_Nullable SuccessBlock)successBlock failureBlock:(_Nullable FailureBlock)failureBlock mainView:(UIView *)mainView
{
 
    
    MBProgressHUD *hud = [self hudWithmainView:mainView];
    
    if (httpRequestType == LSDHttpRequestTypeGET) {
        
        if (_debug) {
            NSLog(@"\nmethod:GET \nurl = %@, \nparameters = \n%@",urlString,parameters);
        }
        
        [_instance GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            if (downloadProgressBlock) {
                downloadProgressBlock(downloadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
            if (_debug) {
                NSLog(@"\nsuccess: \nresponse = \n%@",responseObject);
            }
              [hud hideAnimated:YES];
            if (successBlock) {
                successBlock(responseObject);
            }
            
           
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
            if (_debug) {
                NSLog(@"\nfailure: \nerror = \n%@",error);
            }
              [hud hideAnimated:YES];
            if (failureBlock) {
                failureBlock(error);
            }
       
        }];
    }
    else if (httpRequestType == LSDHttpRequestTypePOST){
        
        
        if (_debug) {
            NSLog(@"\nmethod:POST \nurl = %@,\nparameters = \n%@",urlString,parameters);
        }
        
        [_instance POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            if (downloadProgressBlock) {
                downloadProgressBlock(downloadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            [hud hideAnimated:YES];
            
            if (_debug) {
                NSLog(@"\nsuccess: \nresponse = \n%@",responseObject);
            }
        
            if (successBlock) {
                successBlock(responseObject);
            }
            

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (_debug) {
                NSLog(@"\nfailure: \nerror = \n%@",error);
            }
            
            [hud hideAnimated:YES];
            
            if (failureBlock) {
                failureBlock(error);
            }
           
        }];
        
    }
    else if(httpRequestType == LSDHttpRequestTypeHEAD){
        
        if (_debug) {
            NSLog(@"\nmethod:HEAD \nurl = %@,\nparameters = \n%@",urlString,parameters);
        }
        
        [_instance HEAD:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
        
             [hud hideAnimated:YES];
            
            if (_debug) {
                NSLog(@"\nsuccess: \ntask = \n%@",task);
            }
            
            if (successBlock) {
                successBlock(task);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 
            [hud hideAnimated:YES];
            
            if (_debug) {
                NSLog(@"\nfailure: \nerror = \n%@",error);
            }
            
            if (failureBlock) {
                failureBlock(error);
            }
        }];
        
    }
    
}

#pragma mark -- 上传图片到服务器上(支持多张上传)
-(void)lsd_upLoadDataToNetWorkWithUrlString:(nonnull NSString *)urlString parameters:(nullable id)parameters fileDataArray:(nullable NSArray *)fileDataArray serverName:(nonnull NSString *)serverName fileName:(nonnull NSString *)fileName progress:(nullable UploadProgressBlock)uploadProgressBlock successBlock:(nullable SuccessBlock)successBlock failureBlock:(nullable FailureBlock)failureBlock mainView:(UIView *)mainView
{
    
    // 获取转圈控件
    MBProgressHUD *hud = [self hudWithmainView:mainView];
    
    [_instance POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSMutableArray *muArray = [NSMutableArray array];
  
        for (UIImage  *image in fileDataArray) {
            
            NSData *data =  UIImageJPEGRepresentation(image, 0.9);
            [muArray addObject:data];
            
        }
        
        for (int i = 0; i < muArray.count ; i ++)
        {
            [formData appendPartWithFileData:[muArray objectAtIndex:i] name:[NSString stringWithFormat:@"%@[%d]",serverName,i] fileName:[NSString stringWithFormat:@"%@%d.jpg",fileName,i] mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
         [hud hideAnimated:YES];
        
        if (successBlock) {
            successBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

          [hud hideAnimated:YES];
        
        if (failureBlock) {
            failureBlock(error);
        }
        
    }];
    
}


#pragma mark -- 上传图片到服务器上(支持一个Key一个图片上传)
-(void)lsd_upLoadDataToNetWorkWithUrlString:(nonnull NSString *)urlString parameters:(nullable id)parameters fileDataArray:(nullable NSArray *)fileDataArray serverNameArray:(nullable NSArray *)serverNameArray fileNameArray:(nullable NSArray *)fileNameArray progress:(nullable UploadProgressBlock)uploadProgressBlock successBlock:(nullable SuccessBlock)successBlock failureBlock:(nullable FailureBlock)failureBlock mainView:(UIView *)mainView
{
    
    // 获取转圈控件
    MBProgressHUD *hud = [self hudWithmainView:mainView];
    
    [_instance POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSMutableArray *muArray = [NSMutableArray array];
        for (UIImage  *image in fileDataArray) {
            
            NSData *data =  UIImageJPEGRepresentation(image, 0.9);
            [muArray addObject:data];
            
        }
   
        for (int i = 0; i < muArray.count ; i ++)
        {
            [formData appendPartWithFileData:[muArray objectAtIndex:i] name:serverNameArray[i] fileName:[NSString stringWithFormat:@"%@.jpg",fileNameArray[i]] mimeType:@"image/jpeg"];
        }
    
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [hud hideAnimated:YES];
        
        if (successBlock) {
            successBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [hud hideAnimated:YES];
        
        if (failureBlock) {
            failureBlock(error);
        }
        
    }];
    
}


#pragma mark -- 检查请求地址中是否有中文 下载文件时使用
+ (nullable NSString *)lsd_strUTF8Encoding:(nullable NSString *)str;
{
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
}


#pragma mark -- 下载文件
-(void)lsd_downLoadDataWithUrlString:(nullable NSString *)urlString SaveToPath:(nullable NSString *)saveToPath progressBlock:(DownloadProgressBlock)downloadProgressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    
    ///检查是否有中文  如果有中文 则[NSURL URLWithString:urlString]不存在为nil
    NSString *urlStr = [NSURL URLWithString:urlString] ? urlString:[LSDHTTPNetWorkTool lsd_strUTF8Encoding:urlString];
    
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于URLSession的
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    self.downloadManager = manager;
    
    self.downLoadSession = manager.session;
    
    self.downloadOperationQueue = manager.operationQueue;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if(downloadProgressBlock){
            downloadProgressBlock(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        ///注意使用fileURLWithPath设置本地路径url
        return [NSURL fileURLWithPath:saveToPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error == nil){
            
            if (successBlock) {
                successBlock(filePath.absoluteString);
            }
        }else{
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
    
    [downloadTask resume];
    
    self.downloadTask = downloadTask;
    
}

#pragma mark -- 断线续传功能
- (void)lsd_suspends{
    
    [self.downloadTask suspend];
}
- (void)lsd_resume{
    
    [self.downloadTask resume];
}

- (void)lsd_cancel {
    
    [self.downloadTask cancel];
    
}


#pragma mark -- MBProgressHUD的使用
- (MBProgressHUD *)hudWithmainView:(UIView *)mainView{
    
    if (mainView == nil) {
        return  nil;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mainView animated:YES];
    
    return hud;
}



@end










