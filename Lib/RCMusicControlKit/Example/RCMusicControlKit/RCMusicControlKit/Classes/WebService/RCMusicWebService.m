//
//  RCMusicWebService.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import "RCMusicWebService.h"
#import "HFOpenApiManager.h"
#import "NSObject+YYModel.h"
#import "RCMusicChannelResponse.h"
#import "RCMusicSheetResponse.h"
#import "RCMusicResponse.h"
#import "RCMusicDetail.h"

@implementation RCMusicWebService

+(void)channelWithSuccess:(void (^)(NSArray<RCMusicChannelData *> * _Nullable response))success
                     fail:(void (^)(NSError *error))failure {
    [[HFOpenApiManager shared] channelWithSuccess:^(id  _Nullable response) {
        if (success) {
            NSMutableArray *marr = [@[] mutableCopy];
            if ([response isKindOfClass:[NSArray class]]) {
                for (NSDictionary *data in response) {
                    if (data) {
                        RCMusicChannelData *resData = [RCMusicChannelData yy_modelWithDictionary:data];
                        if (resData) {
                            [marr addObject:resData];
                        }
                    }
                }
            }
            success([marr copy]);
        }
        
    } fail:failure];
}

+(void)channelSheetWithGroupId:(nullable NSString *)groupId
                      language:(nullable NSString *)language
                       recoNum:(nullable NSString *)recoNum
                          page:(nullable NSString *)page
                      pageSize:(nullable NSString *)pageSize
                       success:(void (^)(RCMusicSheetData * _Nullable response))success
                          fail:(void (^)(NSError *error))failure {
    [[HFOpenApiManager shared] channelSheetWithGroupId:groupId language:language recoNum:recoNum page:page pageSize:pageSize success:^(id  _Nullable response) {
        if (success) {
            RCMusicSheetData *res = [RCMusicSheetData yy_modelWithDictionary:response];
            if (res == nil) {
                NSLog(@"RCMusicSheetResponse parsing error");
            }
            success(res);
        }
    } fail:failure];
}

+(void)sheetMusicWithSheetId:(nullable NSString *)sheetId
                    language:(nullable NSString *)language
                        page:(nullable NSString *)page
                    pageSize:(nullable NSString *)pageSize
                     success:(void (^)(RCMusicData * _Nullable response))success
                        fail:(void (^)(NSError *error))failure {
    [[HFOpenApiManager shared] sheetMusicWithSheetId:sheetId language:language page:page pageSize:pageSize success:^(id  _Nullable response) {
        if (success) {
            RCMusicData *res = [RCMusicData yy_modelWithDictionary:response];
            if (res == nil) {
                NSLog(@"RCMusicResponse parsing error");
            }
            success(res);
        }
    } fail:failure];
}

+ (void)trafficHQListenWithMusicId:(nonnull NSString *)musicId
                      audioFormat:(nullable NSString *)audioFormat
                        audioRate:(nullable NSString *)audioRate
                          success:(void (^)(RCMusicDetail  * _Nullable response))success
                             fail:(void (^)(NSError * _Nullable error))failure {
    [[HFOpenApiManager shared] trafficHQListenWithMusicId:musicId audioFormat:audioFormat audioRate:audioRate success:^(id  _Nullable response) {
        if (success) {
            RCMusicDetail *res = [RCMusicDetail yy_modelWithDictionary:response];
            if (res == nil) {
                NSLog(@"RCMusicDetail parsing error");
            }
            success(res);
        }
    } fail:failure];
}

+ (void)searchMusicWithTagIds:(NSString *_Nullable)tagIds
               priceFromCent:(NSString *_Nullable)priceFromCent
                 priceToCent:(NSString *_Nullable)priceToCent
                     bpmFrom:(NSString *_Nullable)bpmFrom
                       bpmTo:(NSString *_Nullable)bpmTo
                durationFrom:(NSString *_Nullable)durationFrom
                  durationTo:(NSString *_Nullable)durationTo
                     keyword:(NSString *_Nullable)keyword
                    language:(NSString *_Nullable)language
                 searchFiled:(NSString *_Nullable)searchFiled
                 searchSmart:(NSString *_Nullable)searchSmart
                        page:(NSString *_Nullable)page
                    pageSize:(NSString *_Nullable)pageSize
                     success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail {
    [[HFOpenApiManager shared] searchMusicWithTagIds:tagIds priceFromCent:priceFromCent priceToCent:priceToCent bpmFrom:bpmFrom bpmTo:bpmTo durationFrom:durationFrom durationTo:durationTo keyword:keyword language:language searchFiled:searchFiled searchSmart:searchSmart page:page pageSize:pageSize success:success fail:fail];
}

@end
