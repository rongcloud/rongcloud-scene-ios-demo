//
//  HFVNetWork.h
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/2.
//

#import <Foundation/Foundation.h>
#import "HFVLibUtils.h"
#import "NSMutableDictionary+SafeAccess.h"
#import "NSMutableArray+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"
#import "HFOpenApiManager.h"
#import "HFVLibUtils.h"


NS_ASSUME_NONNULL_BEGIN


@interface HFVNetWork : NSObject<NSURLSessionDelegate>

@property(nonatomic,copy)NSString *baseUrl;
@property(nonatomic,strong)NSURLSession *session;

- (NSString *)convertQuery:(NSDictionary *)dic;

- (void)getRequestWithAction:(NSString *)action queryParams:(NSDictionary * _Nullable )queryParams needToken:(BOOL)needToken success:(void (^)(id _Nullable response))success fail:(void (^)(NSError * _Nullable error))fail;

- (void)postRequestWithAction:(NSString *)action queryParams:(NSDictionary * _Nullable)queryParams bodyParams:(NSDictionary * _Nullable)bodyParams needToken:(BOOL)needToken success:(void (^)(id _Nullable response))success fail:(void (^)(NSError * _Nullable error))fail;

- (NSURLSessionDataTask *)resumeTaskWithRequest:(NSURLRequest *)request callWithSuccess:(void (^)(id _Nullable response))success fail:(void (^)(NSError * _Nullable error))fail;



-(void)configErrorNotificationCode:(NSUInteger)code msg:(NSString *)msg;






@end

NS_ASSUME_NONNULL_END
