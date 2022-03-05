//
//  HFVLibInfo.m
//  HFVMusic
//
//  Created by 灏 孙  on 2019/7/23.
//  Copyright © 2019 HiFiVe. All rights reserved.
//

#import "HFVLibInfo.h"
#import "HFVLibUtils.h"


@interface HFVLibInfo()

@end

@implementation HFVLibInfo

static HFVLibInfo *hfv_info = nil;

+ (HFVLibInfo *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hfv_info = [HFVLibInfo new];

        hfv_info.pg = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        hfv_info.domain = @"https://gateway.open.hifiveai.com";
        hfv_info.platform = @"PLATFORM_IOS";

    });
    return hfv_info;
}


- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
}

//- (void)setAccessToken_sociaty:(NSString *)accessToken_sociaty {
//    _accessToken_sociaty = accessToken_sociaty;
//    if (accessToken_sociaty != nil) {
//        _accessToken_member = nil;
//    }
//}

@end
