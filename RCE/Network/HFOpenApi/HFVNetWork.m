//
//  HFVNetWork.m
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/2.
//

#import "HFVNetWork.h"
#import "HFVLibInfo.h"
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SCNetworkReachability.h>



#ifdef DEBUG
#define HFAPILog(...) NSLog(__VA_ARGS__)
#else
#define HFAPILog(...)
#endif
@implementation HFVNetWork

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    return self;
}

- (NSString *)baseUrl {
    return [HFVLibInfo shared].domain;
}

- (int)updateHeaderForRequest:(NSMutableURLRequest *)request action:(NSString *)action params:(NSDictionary *)params neeHFAPILogin:(BOOL)neeHFAPILogin error:(NSError **)error {
    if ([HFVLibUtils isBlankString:[HFVLibInfo shared].appId]) {
        *error = HFVMusicError(HFVSDK_CODE_NoRegister, @"未注册");
        [self configErrorNotificationCode:HFVSDK_CODE_NoRegister msg:@"未注册"];
        return -1;
    }
    if ([HFVLibUtils isBlankString:[HFVLibInfo shared].secret]) {
        *error = HFVMusicError(HFVSDK_CODE_NoRegister, @"未注册");
        [self configErrorNotificationCode:HFVSDK_CODE_NoRegister msg:@"未注册"];
        return -1;
    }
    if (neeHFAPILogin && [HFVLibUtils isBlankString:[HFVLibInfo shared].accessToken]) {
        *error = HFVMusicError(HFVSDK_CODE_NoLogin, @"未登录");
        [self configErrorNotificationCode:HFVSDK_CODE_NoLogin msg:@"未登录"];
        return -1;
    }
    //时间戳
    NSString *timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970] * 1000];
    //随机32位字符串
    NSString *random = [HFVLibUtils generateTradeNO:32];
    //加密签名
    NSString *sign = [self makeSignMethod:request.HTTPMethod action:action params:params timestamp:timestamp random:random error:error];
    if (!sign) {
        //签名错误
        [self configErrorNotificationCode:HFVSDK_CODE_ParameterError msg:@"参数字符格式签名错误"];
        return -1;
    }
    NSString *authorization = [NSString stringWithFormat:@"HF3-HMAC-SHA1 Signature=%@",sign];
    
    //设置request的header
    [request setValue:action forHTTPHeaderField:@"X-HF-Action"];
    [request setValue:[HFVLibInfo shared].version forHTTPHeaderField:@"X-HF-Version"];
    [request setValue:[HFVLibInfo shared].appId forHTTPHeaderField:@"X-HF-AppId"];
    [request setValue:timestamp forHTTPHeaderField:@"X-HF-Timestamp"];
    [request setValue:random forHTTPHeaderField:@"X-HF-Nonce"];
    [request setValue:[HFVLibInfo shared].clientId forHTTPHeaderField:@"X-HF-ClientId"];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    if (neeHFAPILogin) {
        [request setValue:[HFVLibInfo shared].accessToken forHTTPHeaderField:@"X-HF-Token"];
    }
    return 0;
}

- (NSString *)convertQuery:(NSDictionary *)dic {
    NSMutableString *mutStr = [[NSMutableString alloc]init];
    NSArray *allKeys = dic.allKeys;
    @autoreleasepool {
        for (int i = 0; i < allKeys.count; i ++) {
            NSString *key = allKeys[i];
            NSString*value = dic[key];
            [mutStr appendFormat:@"%@=%@&",key,value];
        }
    }
    if (mutStr.length > 0) {
        [mutStr deleteCharactersInRange:NSMakeRange([mutStr length] - 1,1)];
    }
    return mutStr;
}


- (NSString *)convertBody:(NSDictionary *)dic {
    NSMutableString *mutStr = [[NSMutableString alloc]init];
    NSArray *allKeys = dic.allKeys;
    
    for (int i = 0; i < allKeys.count; i ++) {
        NSString *key = allKeys[i];
        NSString*value = dic[key];
        [mutStr appendFormat:@"%@%@=%@",i == 0 ? @"" : @"&&",key,value];
    }
    return mutStr;
}

-(void)getRequestWithAction:(NSString *)action queryParams:(NSDictionary *)queryParams needToken:(BOOL)needToken success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSString *full = self.baseUrl;
    if (queryParams.count != 0) {
        NSString *query = [self convertQuery:[HFVLibUtils urlEncodeWithDIctionary:queryParams]];
        full = [NSString stringWithFormat:@"%@?%@",self.baseUrl,query];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:full]];
    request.HTTPMethod = @"GET";
    NSError *header_error;
    int state = [self updateHeaderForRequest:request action:action params:queryParams neeHFAPILogin:needToken error:&header_error];
    if (header_error) {
        fail(header_error);
        return;
    }
    if (state != 0) {
        fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不全"));
        return;
    }
    [self resumeTaskWithRequest:request callWithSuccess:success fail:fail];
}

-(void)postRequestWithAction:(NSString *)action queryParams:(NSDictionary *)queryParams bodyParams:(NSDictionary *)bodyParams needToken:(BOOL)needToken success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSString *full = self.baseUrl;
    //    if (queryParams.count != 0) {
    //        NSString *query = [self convertQuery:[HFVLibUtils urlEncodeWithDIctionary:queryParams]];
    //        full = [NSString stringWithFormat:@"%@?%@",full,query];
    //    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:full]];
    request.HTTPMethod = @"POST";
    NSError *header_error;
    int state = [self updateHeaderForRequest:request action:action params:bodyParams neeHFAPILogin:needToken error:&header_error];
    if (header_error) {
        fail(header_error);
        return;
    }
    if (state != 0) {
        fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不全"));
        return;
    }
    if (bodyParams.count != 0) {
        //request.HTTPBody = [[self convertBody:[HFVLibUtils urlEncodeWithDIctionary:bodyParams]] dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = [[self convertBody:bodyParams] dataUsingEncoding:NSUTF8StringEncoding];
    }
    [self resumeTaskWithRequest:request callWithSuccess:success fail:fail];
}
- (NSURLSessionDataTask *)resumeTaskWithRequest:(NSMutableURLRequest *)request callWithSuccess:(void (^)(id _Nullable response))success fail:(void (^)(NSError * _Nullable error))fail {
    if (![self isNetworkEnabled]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoNetwork, @"当前网络不可用，请检查网络连接"));
        }
        [self configErrorNotificationCode:HFVSDK_CODE_NoNetwork msg:@"当前网络不可用，请检查网络连接"];
        return nil;
    }
    HFAPILog(@"\n⬇️⬇️⬇️⬇️\nurl = %@\n⬆️⬆️⬆️⬆️",request.URL);
    HFAPILog(@"\n⬇️⬇️⬇️⬇️\nmethod = %@\n⬆️⬆️⬆️⬆️",request.HTTPMethod);
    HFAPILog(@"\n⬇️⬇️⬇️⬇️\nheader = %@\n⬆️⬆️⬆️⬆️",request.allHTTPHeaderFields);
    HFAPILog(@"\n⬇️⬇️⬇️⬇️\nbody = %@\n⬆️⬆️⬆️⬆️",request.HTTPBody);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (fail) {
                    if (error.code == -1001) {
                        fail(HFVMusicError(HFVSDK_CODE_RequestTimeOut, @"请求超时"));
                        [self configErrorNotificationCode:HFVSDK_CODE_RequestTimeOut msg:@"请求超时"];
                    } else {
                        
                    }
                }
            }else{
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    
                    int code = [[dic hfv_objectForKey_Safe:@"code"] intValue];
                    id data = [dic hfv_objectForKey_Safe:@"data"];
#ifdef DEBUG
                    HFAPILog(@"\n⬇️⬇️⬇️⬇️\n%@\n⬆️⬆️⬆️⬆️\n",[dic description]);
#endif
                    if (code == 10200 || code == 200) {
                        if (success) {
                            success(data);
                        }
                    }else {
                        if (fail) {
                            fail([[NSError alloc] initWithDomain:HFVMusicDomain code:code userInfo:dic]);
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:KHFVNotification_Api_ServerError object:nil userInfo:dic];
                    }
                }else {
                    //数据异常
                    if (fail) {
                        fail(HFVMusicError(HFVSDK_CODE_JsonError, @""));
                    }
                    //                    [self configErrorNotificationCode:HFVSDK_CODE_JsonError msg:@"数据异常"];
                }
            }
        });
    }];
    [task resume];
    return task;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){//服务器信任证书
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//服务器信任证书
        if(completionHandler)
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}


//-判断当前网络是否可用
-(BOOL)isNetworkEnabled {
    BOOL bEnabled = FALSE;
    NSString *url = @"www.baidu.com";
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [url UTF8String]);
    SCNetworkReachabilityFlags flags;
    bEnabled = SCNetworkReachabilityGetFlags(ref, &flags);
    CFRelease(ref);
    if (bEnabled) {
        //kSCNetworkReachabilityFlagsReachable：能够连接网络
        //kSCNetworkReachabilityFlagsConnectionRequired：能够连接网络，但是首先得建立连接过程
        //kSCNetworkReachabilityFlagsIsWWAN：判断是否通过蜂窝网覆盖的连接，比如EDGE，GPRS或者目前的3G.主要是区别通过WiFi的连接。
        BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
        bEnabled = ((flagsReachable && !connectionRequired) || nonWiFi) ? YES : NO;
    }
    return bEnabled;
}

//通知
-(void)configErrorNotificationCode:(NSUInteger)code msg:(NSString *)msg {
    NSDictionary *info = @{@"code":[NSString stringWithFormat:@"%lu",(unsigned long)code],
                           @"msg": msg};
    [[NSNotificationCenter defaultCenter] postNotificationName:KHFVNotification_Api_RequestError object:nil userInfo:info];
}

//签名
-(NSString *)makeSignMethod:(NSString *)method action:(NSString *)action params:(NSDictionary *)params timestamp:(NSString *)timestamp random:(NSString *)random error:(NSError **)error{
    //1. 把请求的参数(除公共参数)规范成字符串
    NSString *paramsStr = @"";
    if (params.count != 0) {
        paramsStr = [self getParamsStringWithParams: params];
    }
    HFAPILog(@"签名one：%@",paramsStr);
    //2. 把请求方式(get or post) 和 公共参数的值，按照公共参数的顺序排列，中间以空格隔开
    //NSString *publicParamsStr = @"GET TrafficTagSheet V4.0.1 170ae316b9b14c1b9c185988771bde16 CgA1cq9jpI3Ku5JiwMwuPuqzWY30trM5 hf2y7jk19a56qetq05 HF3-HMAC-SHA1 1594696782451";
    //Method X-HF-Action、X-HF-Version、X-HF-AppId、X-HF-Nonce、X-HF-ClientId、'HF3-HMAC-SHA1'、X-HF-Timestamp
    NSString *publicParamsStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@",method,action,[HFVLibInfo shared].version,[HFVLibInfo shared].appId,random,[HFVLibInfo shared].clientId,@"HF3-HMAC-SHA1",timestamp];
    HFAPILog(@"签名two：---%@",publicParamsStr);
    //3. 把步骤2的结果做base64编码
    NSString *base64Str = [HFVLibUtils base64EncodeString:publicParamsStr];
    HFAPILog(@"签名three:%@",base64Str);
    //4. 合并步骤1和3的结果，得到待签名的字符串
    NSString *beforSign;
    if (paramsStr.length>0) {
        beforSign = [NSString stringWithFormat:@"%@&%@",paramsStr,base64Str];
    } else {
        beforSign = base64Str;
    }
    HFAPILog(@"签名four:%@",beforSign);
    
    //5. 签名
    NSString *a = [HFVLibUtils base64EncodeString:beforSign];
    HFAPILog(@"签名five：%@",a);
    NSString *b = [HFVLibUtils hmacSHA1String:a Key:[HFVLibInfo shared].secret error:error];
    if (!b) {
        HFAPILog(@"签名失败");
    }
    HFAPILog(@"最终结果:%@",b);
    return b;
}

-(NSString *)getParamsStringWithParams:(NSDictionary *)params {
    NSMutableString *resultStr = [NSMutableString stringWithCapacity:0];
    NSArray *keys = params.allKeys;
    //按照字典排序
    NSArray *sortArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *key in sortArray) {
        NSString *tempStr = [NSString stringWithFormat:@"%@=%@&",key, [params hfv_objectForKey_Safe:key]];
        [resultStr appendString:tempStr];
    }
    if (resultStr.length > 0) {
        [resultStr deleteCharactersInRange:NSMakeRange([resultStr length] - 1,1)];
    }
    return resultStr;
}
@end
