//
//  HFVLibInfo.h
//  HFVMusic
//
//  Created by 灏 孙  on 2019/7/23.
//  Copyright © 2019 HiFiVe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFVLibInfo : NSObject
+ (HFVLibInfo *)shared;

@property (nonatomic, copy) NSString *libVersion;
@property (nonatomic, copy) NSString *appBundleId;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, assign) BOOL isDebug;

/**
 应用id
 */
@property (nonatomic, copy) NSString *appId;

/**
 应用secret
 */
@property (nonatomic, copy) NSString *secret;

/**
 用户生成的id
 */
@property (nonatomic, copy) NSString *clientId;

/**
 API版本
 */
@property (nonatomic, copy) NSString *version;

/**
 服务器地址
 */
@property (nonatomic, copy) NSString *domain;

/**
 包路径
 */
@property (nonatomic, copy) NSString *pg;

/**
 设备id
 */
@property (nonatomic, copy) NSString *vendorId;

/**
 平台
 */
@property (nonatomic, copy) NSString *platform;

/**
 平台
 */
@property (nonatomic, copy) NSString *musicLanguage;

/**----------------------------------------------------------- 以上为公有，必须有的 ----------------------------------------------------------------------*/


/**
 会员ID
 */
@property (nonatomic, copy,nullable) NSString *memberId;

/**
 公会ID
 */
@property (nonatomic, copy,nullable) NSString *sociatyId;

@property (nonatomic, copy,nullable) NSString *accessToken;



@end

NS_ASSUME_NONNULL_END
