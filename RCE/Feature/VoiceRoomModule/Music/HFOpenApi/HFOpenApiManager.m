//
//  HFOpenApiManager.m
//  HFOpenApi
//
//  Created by 郭亮 on 2021/3/16.
//

#import "HFOpenApiManager.h"
#import "HFVLibInfo.h"
#import "HFOpenAction.h"
#import "HFVLibUtils.h"
#import "HFVNetWork.h"

@interface HFOpenApiManager ()

@property(nonatomic ,strong)HFVNetWork *netWork;

@end

@implementation HFOpenApiManager

static HFOpenApiManager *manager = nil;

+(HFOpenApiManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[HFOpenApiManager alloc] init];
            [manager configNotif];
        }
    });
    return manager;
}

-(void)configNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiRequestErrorNotificationHandle:) name:KHFVNotification_Api_RequestError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiServerErrorNotificationHandle:) name:KHFVNotification_Api_ServerError object:nil];
}

-(void)apiRequestErrorNotificationHandle:(NSNotification *)notif {
    if ([self.delegate respondsToSelector:@selector(onSendRequestErrorCode:info:)]) {
        NSDictionary *dic = notif.userInfo;
        int code = [[dic hfv_objectForKey_Safe:@"code"] intValue];
        [self.delegate onSendRequestErrorCode:code info:dic];
    }
}

-(void)apiServerErrorNotificationHandle:(NSNotification *)notif {
    if ([self.delegate respondsToSelector:@selector(onServerErrorCode:info:)]) {
        NSDictionary *dic = notif.userInfo;
        int code = [[dic hfv_objectForKey_Safe:@"code"] intValue];
        [self.delegate onServerErrorCode:code info:dic];
    }
}

-(HFVNetWork *)netWork {
    if (!_netWork) {
        _netWork = [[HFVNetWork alloc] init];
    }
    return _netWork;
}

-(void)registerAppWithAppId:(NSString *)appId serverCode:(NSString *)serverCode clientId:(NSString *)clientId version:(NSString *)version success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:appId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    if ([HFVLibUtils isBlankString:serverCode]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    if ([HFVLibUtils isBlankString:clientId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    if ([HFVLibUtils isBlankString:version]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    [HFVLibInfo shared].appId = appId;
    [HFVLibInfo shared].secret = serverCode;
    [HFVLibInfo shared].clientId = clientId;
    [HFVLibInfo shared].version = version;
    if (success) {
        success(@"注册成功");
    }
}

-(void)channelWithSuccess:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    [self.netWork getRequestWithAction:Action_Channel queryParams:nil needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)baseLoginWithNickname:(NSString *)nickname gender:(NSString *)gender birthday:(NSString *)birthday location:(NSString *)location education:(NSString *)education profession:(NSString *)profession isOrganization:(BOOL)isOrganization reserve:(NSString *)reserve favoriteSinger:(NSString *)favoriteSinger favoriteGenre:(NSString *)favoriteGenre success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params hfv_setObject_Safe:nickname forKey:@"Nickname"];
    [params hfv_setObject_Safe:gender forKey:@"Gender"];
    [params hfv_setObject_Safe:birthday forKey:@"Birthday"];
    [params hfv_setObject_Safe:location forKey:@"Location"];
    [params hfv_setObject_Safe:education forKey:@"Education"];
    [params hfv_setObject_Safe:profession forKey:@"Profession"];
    [params hfv_setObject_Safe:@(isOrganization) forKey:@"IsOrganization"];
    [params hfv_setObject_Safe:reserve forKey:@"Reserve"];
    [params hfv_setObject_Safe:favoriteSinger forKey:@"FavoriteSinger"];
    [params hfv_setObject_Safe:favoriteGenre forKey:@"FavoriteGenre"];
    [params hfv_setObject_Safe:[HFVLibInfo shared].appId forKey:@"AppId"];
    NSString *timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970] * 1000];
    [params hfv_setObject_Safe:timestamp forKey:@"Timestamp"];
    [self.netWork postRequestWithAction:Action_BaseLogin queryParams:nil bodyParams:params needToken:NO success:^(id  _Nullable response) {
        //存储token
        NSDictionary *dic = response;
        [HFVLibInfo shared].accessToken = [dic hfv_objectForKey_Safe:@"token"];
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)channelSheetWithGroupId:(NSString *)groupId language:(NSString *)language recoNum:(NSString *)recoNum page:(NSString *)page pageSize:(NSString *)pageSize success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:groupId forKey:@"GroupId"];
    [params hfv_setObject_Safe:language forKey:@"Language"];
    [params hfv_setObject_Safe:recoNum forKey:@"RecoNum"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    
    [self.netWork getRequestWithAction:ACtion_ChannelSheet queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)sheetMusicWithSheetId:(NSString *)sheetId language:(NSString *)language page:(NSString *)page pageSize:(NSString *)pageSize success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:sheetId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
    [params hfv_setObject_Safe:language forKey:@"Language"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    
    [self.netWork getRequestWithAction:Action_SheetMusic queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)searchMusicWithTagIds:(NSString *)tagIds priceFromCent:(NSString *)priceFromCent priceToCent:(NSString *)priceToCent bpmFrom:(NSString *)bpmFrom bpmTo:(NSString *)bpmTo durationFrom:(NSString *)durationFrom durationTo:(NSString *)durationTo keyword:(NSString *)keyword language:(NSString *)language searchFiled:(NSString *)searchFiled searchSmart:(NSString *)searchSmart page:(NSString *)page pageSize:(NSString *)pageSize success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:tagIds forKey:@"TagIds"];
    [params hfv_setObject_Safe:priceFromCent forKey:@"PriceFromCent"];
    [params hfv_setObject_Safe:priceToCent forKey:@"PriceToCent"];
    [params hfv_setObject_Safe:bpmFrom forKey:@"BpmFrom"];
    [params hfv_setObject_Safe:bpmTo forKey:@"BpmTo"];
    [params hfv_setObject_Safe:durationFrom forKey:@"DurationFrom"];
    [params hfv_setObject_Safe:durationTo forKey:@"DurationTo"];
    [params hfv_setObject_Safe:keyword forKey:@"Keyword"];
    [params hfv_setObject_Safe:language forKey:@"Language"];
    [params hfv_setObject_Safe:searchFiled forKey:@"SearchFiled"];
    [params hfv_setObject_Safe:searchSmart forKey:@"SearchSmart"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    
    [self.netWork postRequestWithAction:Action_SearchMusic queryParams:nil bodyParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}


-(void)musicConfigWithSuccess:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    [self.netWork getRequestWithAction:Action_MusicConfig queryParams:nil needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)baseFavoriteWithPage:(NSString *)page pageSize:(NSString *)pageSize success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    
    [self.netWork getRequestWithAction:Action_BaseFavorite queryParams:params needToken:YES success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)baseHotWithStartTime:(NSString *)startTime duration:(NSString *)duration page:(NSString *)page pageSize:(NSString *)pageSize success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:startTime]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:duration]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:startTime forKey:@"StartTime"];
    [params hfv_setObject_Safe:duration forKey:@"Duration"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    
    [self.netWork getRequestWithAction:Action_BaseHot queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)trialWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_Trial queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)trafficTrialWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_TrafficTrial queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)ugcTrialWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_UGCTrial queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

- (void)kTrialWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_KTrial queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)orderTrialWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_OrderTrial queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)trafficHQListenWithMusicId:(NSString *)musicId audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
    
    [self.netWork getRequestWithAction:Action_TrafficHQListen queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)ugcHQListenWithMusicId:(NSString *)musicId audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
    
    [self.netWork getRequestWithAction:Action_UGCHQListen queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)kHQListenWithMusicId:(NSString *)musicId audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
    
    [self.netWork getRequestWithAction:Action_KHQListen queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)trafficListenMixedWithMusicId:(NSString *)musicId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    
    [self.netWork getRequestWithAction:Action_TrafficListenMixed queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)orderMusicWithSubject:(NSString *)subject orderId:(NSString *)orderId deadline:(NSString *)deadline music:(NSString *)music language:(NSString *)language audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate totalFee:(NSString *)totalFee remark:(NSString *)remark workId:(NSString *)workId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:subject]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:orderId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:deadline]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:music]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:totalFee]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:subject forKey:@"Subject"];
    [params hfv_setObject_Safe:orderId forKey:@"OrderId"];
    [params hfv_setObject_Safe:deadline forKey:@"Deadline"];
    [params hfv_setObject_Safe:music forKey:@"Music"];
    [params hfv_setObject_Safe:language forKey:@"Language"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
    [params hfv_setObject_Safe:totalFee forKey:@"TotalFee"];
    [params hfv_setObject_Safe:remark forKey:@"Remark"];
    [params hfv_setObject_Safe:workId forKey:@"WorkId"];
    
    [self.netWork postRequestWithAction:Action_OrderMusic queryParams:nil bodyParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)orderDetailWithOrderId:(NSString *)orderId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:orderId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:orderId forKey:@"OrderId"];
    [self.netWork getRequestWithAction:Action_OrderDetail queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)orderAuthorizationWithCompanyName:(NSString *)companyName projectName:(NSString *)projectName brand:(NSString *)brand period:(NSString *)period area:(NSString *)area orderIds:(NSString *)orderIds success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:companyName]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:projectName]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:brand]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:period]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:area]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:orderIds]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:companyName forKey:@"CompanyName"];
    [params hfv_setObject_Safe:projectName forKey:@"ProjectName"];
    [params hfv_setObject_Safe:brand forKey:@"Brand"];
    [params hfv_setObject_Safe:period forKey:@"Period"];
    [params hfv_setObject_Safe:area forKey:@"Area"];
    [params hfv_setObject_Safe:orderIds forKey:@"OrderIds"];
    [self.netWork getRequestWithAction:Action_OrderAuthorization queryParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)baseReportWithAction:(NSString *)action targetId:(NSString *)targetId content:(NSString *)content location:(NSString *)location success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:action]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:targetId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:action forKey:@"Action"];
    [params hfv_setObject_Safe:targetId forKey:@"TargetId"];
    [params hfv_setObject_Safe:content forKey:@"Content"];
    [params hfv_setObject_Safe:location forKey:@"Location"];
    [self.netWork postRequestWithAction:Action_BaseReport queryParams:nil bodyParams:params needToken:YES success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)orderPublishWithOrderId:(NSString *)orderId workId:(NSString *)workId success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {

    if ([HFVLibUtils isBlankString:orderId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:workId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:orderId forKey:@"OrderId"];
    [params hfv_setObject_Safe:workId forKey:@"WorkId"];
    [self.netWork postRequestWithAction:Action_OrderPublish queryParams:nil bodyParams:params needToken:NO success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)trafficReportListenWithMusicId:(NSString *)musicId duration:(NSString *)duration timestamp:(NSString *)timestamp audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:duration]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:timestamp]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioFormat]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioRate]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:duration forKey:@"Duration"];
    [params hfv_setObject_Safe:timestamp forKey:@"Timestamp"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
//    [self.netWork getRequestWithAction:Action_TrafficReportListen queryParams:params needToken:false success:^(id  _Nullable response) {
//        if (success) {
//            success(response);
//        }
//    } fail:^(NSError * _Nullable error) {
//        if (fail) {
//            fail(error);
//        }
//    }];
    [self.netWork postRequestWithAction:Action_TrafficReportListen queryParams:nil bodyParams:params needToken:false success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)ugcReportListenWithMusicId:(NSString *)musicId duration:(NSString *)duration timestamp:(NSString *)timestamp audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:duration]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:timestamp]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioFormat]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioRate]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:duration forKey:@"Duration"];
    [params hfv_setObject_Safe:timestamp forKey:@"Timestamp"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
//    [self.netWork getRequestWithAction:Action_UGCReportListen queryParams:params needToken:false success:^(id  _Nullable response) {
//        if (success) {
//            success(response);
//        }
//    } fail:^(NSError * _Nullable error) {
//        if (fail) {
//            fail(error);
//        }
//    }];
    [self.netWork postRequestWithAction:Action_UGCReportListen queryParams:nil bodyParams:params needToken:false success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(void)kReportListenWithMusicId:(NSString *)musicId duration:(NSString *)duration timestamp:(NSString *)timestamp audioFormat:(NSString *)audioFormat audioRate:(NSString *)audioRate success:(void (^)(id _Nullable))success fail:(void (^)(NSError * _Nullable))fail {
    if ([HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:duration]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:timestamp]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioFormat]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    if ([HFVLibUtils isBlankString:audioRate]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [params hfv_setObject_Safe:duration forKey:@"Duration"];
    [params hfv_setObject_Safe:timestamp forKey:@"Timestamp"];
    [params hfv_setObject_Safe:audioFormat forKey:@"AudioFormat"];
    [params hfv_setObject_Safe:audioRate forKey:@"AudioRate"];
//    [self.netWork getRequestWithAction:Action_KReportListen queryParams:params needToken:false success:^(id  _Nullable response) {
//        if (success) {
//            success(response);
//        }
//    } fail:^(NSError * _Nullable error) {
//        if (fail) {
//            fail(error);
//        }
//    }];
    [self.netWork postRequestWithAction:Action_KReportListen queryParams:nil bodyParams:params needToken:false success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}


#pragma mark - 会员歌单

/// 创建会员歌单
/// @param sheetName 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)createMemberWithSheetName:(NSString *_Nonnull)sheetName
                      success:(void (^_Nullable)(id  _Nullable response))success
                            fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:sheetName]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetName forKey:@"SheetName"];
  

    [self.netWork postRequestWithAction:Action_CreateMemberSheet queryParams:nil bodyParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 删除会员歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)deleteMemberWithSheetId:(NSString *_Nonnull)sheetId
                      success:(void (^_Nullable)(id  _Nullable response))success
                          fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:sheetId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
  

    [self.netWork postRequestWithAction:Action_DeleteMemberSheet queryParams:nil bodyParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 会员歌单列表
/// @param memberOutId 会员歌单名称
/// @param page 当前页
/// @param pageSize 每页显示条数，默认 10
/// @param success 成功回调
/// @param fail 失败回调
-(void)fetchMemberSheetListWithMemberOutId:(NSString *_Nonnull)memberOutId
                                      page:(NSString *_Nullable)page
                                  pageSize:(NSString *_Nullable)pageSize
                      success:(void (^_Nullable)(id   _Nullable response))success
                                      fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:memberOutId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:memberOutId forKey:@"MemberOutId"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    [self.netWork getRequestWithAction:Action_MemberSheet queryParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 获取会员歌单歌曲
/// @param sheetId 会员歌单名称
/// @param page 当前页
/// @param pageSize 每页显示条数，默认 10
/// @param success 成功回调
/// @param fail 失败回调
-(void)fetchMemberSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                                      page:(NSString *_Nullable)page
                                  pageSize:(NSString *_Nullable)pageSize
                      success:(void (^_Nullable)(id  _Nullable response))success
                                   fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:sheetId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
    [params hfv_setObject_Safe:page forKey:@"Page"];
    [params hfv_setObject_Safe:pageSize forKey:@"PageSize"];
    [self.netWork getRequestWithAction:Action_MemberSheetMusic queryParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 音乐加入歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)addSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                       musicId:(NSString *_Nonnull)musicId
                      success:(void (^_Nullable)(id  _Nullable response))success
                           fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:sheetId] || [HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [self.netWork postRequestWithAction:Action_AddMemberSheetMusic queryParams:nil bodyParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 音乐移除歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)removeSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                       musicId:(NSString *_Nonnull)musicId
                      success:(void (^_Nullable)(id  _Nullable response))success
                              fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    
    if ([HFVLibUtils isBlankString:sheetId] || [HFVLibUtils isBlankString:musicId]) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
    [params hfv_setObject_Safe:musicId forKey:@"MusicId"];
    [self.netWork postRequestWithAction:Action_RemoveMemberSheetMusic queryParams:nil bodyParams:params needToken:true success:^(id  _Nullable response) {
        
        
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}

/// 清空会员歌单音乐列表
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)clearSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                      success:(void (^_Nullable)(id  _Nullable response))success
                             fail:(void (^_Nullable)(NSError * _Nullable error))fail{
    if ([HFVLibUtils isBlankString:sheetId] ) {
        if (fail) {
            fail(HFVMusicError(HFVSDK_CODE_NoParameter, @"参数不完整"));
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params hfv_setObject_Safe:sheetId forKey:@"SheetId"];
    [self.netWork postRequestWithAction:Action_ClearMemberSheetMusic queryParams:nil bodyParams:params needToken:true success:^(id  _Nullable response) {
        if (success) {
            success(response);
        }
    } fail:^(NSError * _Nullable error) {
        if (fail) {
            fail(error);
        }
    }];
}










/// 歌曲试听
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
//-(void)trialWithMusicId:(NSString *_Nonnull)musicId
//                success:(void (^)(id  _Nullable response))success
//                   fail:(void (^)(NSError * _Nullable error))fail;



/// 获取音乐混音播放信息
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
//-(void)trafficListenMixedWithMusicId:(NSString *_Nonnull)musicId
//                             success:(void (^)(id  _Nullable response))success
//                                fail:(void (^)(NSError * _Nullable error))fail;
//




@end
