//
//  RongIMLibExtensionModule.h
//  RongIMLib
//
//  Created by 岑裕 on 16/3/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>

@class RCNaviDataInfo;

@protocol RongIMLibExtensionModule <NSObject>

+ (instancetype)loadRongExtensionModule;

- (void)destroyModule;

- (NSArray<Class> *)getSignalMessageClassList;

- (BOOL)didHoldReceivedMessage:(RCMessage *)message isOffline:(BOOL)offline;

- (void)setAppKey:(NSString *)appKey;

- (void)setConfiguration:(RCNaviDataInfo *)configuration;

- (void)setUserId:(NSString *)userId;

- (void)setCurrentToken:(NSString *)token;

- (void)notifyConnectionStatusChanged:(RCConnectionStatus)status;

- (void)notifyLogoutEvent;

@optional
- (void)setDeviceToken:(NSString *)deviceToken;
//是否占用音频
- (BOOL)isAudioHolding;
//是否占用视频
- (BOOL)isCameraHolding;
@end
