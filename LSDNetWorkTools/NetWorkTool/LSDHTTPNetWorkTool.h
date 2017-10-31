//
//  LSDHTTPNetWorkTool.h
//  LSDNetWorkTools
//
//  Created by ls on 16/6/12.
//  Copyright © 2016年 szrd. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
///网络请求方法
typedef NS_ENUM (NSUInteger, LSDHttpRequestType){
    
    LSDHttpRequestTypeGET,
    LSDHttpRequestTypePOST,
    LSDHttpRequestTypeHEAD
    
};

///下载文件保存路径
typedef NS_ENUM(NSUInteger, LSDDownloadDataPathType){
    
    LSDDownloadDataPathTypCache,
    LSDDownloadDataPathTypeDocument,
    LSDDownloadDataPathTypTemp
    
};


///请求成功后的回调
typedef void(^SuccessBlock)(id _Nullable response);
///请求失败后的回调
typedef void(^FailureBlock)(NSError  * _Nullable error);
///下载数据的进度
typedef void(^DownloadProgressBlock)(NSProgress * _Nonnull downloadProgress);
///上传数据的进度
typedef void(^UploadProgressBlock)(NSProgress * _Nonnull uploadProgress);

@interface LSDHTTPNetWorkTool : AFHTTPSessionManager

///查看网络状态
@property(assign,nonatomic)AFNetworkReachabilityStatus networkStatus;

///单例网络请求管理者
+(nullable instancetype)sharedManager;

#pragma mark -- 配置请求
///更新baseUrl
+(void)lsd_updateBaseUrlWithUrlString:(nullable NSString *)baseUrlString;

// 是否有网络
+ (BOOL)lsd_hasNetworkReachability;

///设置网络超时
+ (void)lsd_setTimeout:(NSTimeInterval)timeout;

///配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
+ (void)lsd_configCommonHttpHeaders:(nullable NSDictionary *)httpHeaders;

///配置请求体格式
-(void)lsd_configRequestSerializer:(nullable AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer;
///配置响应体格式
-(void)lsd_configResponseSerializer:(nullable AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer;

///从网络服务器上获取数据
/*
 httpRequestType : 请求方式
 urlString : 拼接urlString
 parameters : 请求字典参数
 downloadProgressBlock : 下载进度block
 successBlock : 请求成功后的block
 failureBlock : 请求失败后的block
 mainView : hud要添加到的mainView
 */
-(void)lsd_loadDataFromNetWorkWithHttpRequestType:(LSDHttpRequestType)httpRequestType urlString:( NSString * _Nonnull )urlString parameters:(NSDictionary *_Nullable )parameters progressBlock:(_Nullable DownloadProgressBlock)downloadProgressBlock successBlock:(_Nullable SuccessBlock)successBlock failureBlock:(_Nullable FailureBlock)failureBlock mainView:(nullable UIView *)mainView;

///上传文件到网络服务器
/*
 请求方式为POST
 urlString : 拼接urlString
 parameters : 请求字典参数
 fileDataArray : 存放上传文件的数组
 serverName : 要上传到服务器的字段(不包括[])
 fileName : 命名文件名
 uploadProgressBlock : 上传进度block
 successBlock : 请求成功后的block
 failureBlock : 请求失败后的block
 mainView : hud要添加到的mainView
 */
-(void)lsd_upLoadDataToNetWorkWithUrlString:(nonnull NSString *)urlString parameters:(nullable id)parameters fileDataArray:(nullable NSArray *)fileDataArray serverName:(nonnull NSString *)serverName fileName:(nonnull NSString *)fileName progress:(nullable UploadProgressBlock)uploadProgressBlock successBlock:(nullable SuccessBlock)successBlock failureBlock:(nullable FailureBlock)failureBlock mainView:(nullable UIView *)mainView;

/**
 上传图片到服务器上(支持一个Key一个图片上传)

 @param urlString 拼接urlString
 @param parameters 请求字典参数
 @param fileDataArray 图片数组
 @param serverNameArray 要上传到服务器的字段(不包括[])
 @param fileNameArray 命名文件名 注意和图片一一对应
 @param uploadProgressBlock 上传进度block
 @param successBlock 请求成功后的block
 @param failureBlock 请求失败后的block
 @param mainView hud要添加到的mainView
 */
-(void)lsd_upLoadDataToNetWorkWithUrlString:(nonnull NSString *)urlString parameters:(nullable id)parameters fileDataArray:(nullable NSArray *)fileDataArray serverNameArray:(nullable NSArray *)serverNameArray fileNameArray:(nullable NSArray *)fileNameArray progress:(nullable UploadProgressBlock)uploadProgressBlock successBlock:(nullable SuccessBlock)successBlock failureBlock:(nullable FailureBlock)failureBlock mainView:(UIView *_Nullable)mainView;

///下载文件
/*
 urlString : 下载地址
 saveToPath : 要保存的地址
 downloadProgressBlock : 下载进度block
 successBlock : 成功后的block
 failureBlock : 失败后的block
 
 */
-(void)lsd_downLoadDataWithUrlString:(nullable NSString *)urlString SaveToPath:(nullable NSString *)saveToPath progressBlock:(nullable DownloadProgressBlock)downloadProgressBlock successBlock:(nullable SuccessBlock)successBlock failureBlock:(nullable FailureBlock)failureBlock;

#pragma mark -- 下载文件的断点续传
///暂停下载
-(void)lsd_suspends;
///恢复下载
-(void)lsd_resume;
///取消下载
-(void)lsd_cancel;

#pragma mark -- debug调试打印开关
-(void)lsd_configureDebugLogSwitch:(BOOL)debug;


@end
