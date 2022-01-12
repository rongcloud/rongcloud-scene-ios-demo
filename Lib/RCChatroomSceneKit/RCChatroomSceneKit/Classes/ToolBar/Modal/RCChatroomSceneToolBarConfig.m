//
//  RCChatroomSceneConfig.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/3.
//

#import "RCChatroomSceneToolBarConfig.h"
#import "RCAttribute+Convert.h"
#import "RCChatroomSceneConfigHelper.h"
 
@interface RCChatroomSceneToolBarConfig ()

@end

@implementation RCChatroomSceneToolBarConfig

+ (instancetype)default {
    RCChatroomSceneToolBarConfig *config = [RCChatroomSceneConfigHelper configFromJsonForClass:[self class]];
    if (config != nil) {
        return config;
    } else {
        return [self creatPrimaryConfig];
    }
}

+ (RCChatroomSceneToolBarConfig *)creatPrimaryConfig {
    RCChatroomSceneToolBarConfig *config = [[RCChatroomSceneToolBarConfig alloc] init];
    config.chatButtonSize = CGSizeMake(105, 36);
    config.chatButtonTitle = @"聊聊吧...";
    config.chatButtonTextSize = 12.0;
    config.chatButtonTextColor = [UIColor whiteColor];
    config.chatButtonBackgroundColor = [UIColor colorWithWhite:1 alpha:0.26];
    config.chatButtonBackgroundCorner = 18.0;
    config.recordButtonEnable = NO;
    config.recordQuality = RCChatroomSceneRecordQualityLow;
    config.recordButtonPosition = RCChatroomSceneRecordButtonPositionLeft;
    config.commonActions = @[];
    config.actions = @[];
    return config;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _backgroundColor = [RCColor yy_modelWithJSON:dic[@"backgroundColor"]].toUIColor;
    _contentInsets = [RCInsets yy_modelWithJSON:dic[@"contentInsets"]].toUIEdgeInsets;
    _chatButtonSize = [RCSize yy_modelWithJSON:dic[@"chatButtonSize"]].toCGSize;
    _chatButtonInsets = [RCInsets yy_modelWithJSON:dic[@"chatButtonInsets"]].toUIEdgeInsets;
    _chatButtonTextColor = [RCColor yy_modelWithJSON:dic[@"chatButtonTextColor"]].toUIColor;
    _chatButtonBackgroundColor = [RCColor yy_modelWithJSON:dic[@"chatButtonBackgroundColor"]].toUIColor;
    
    NSInteger quality = [dic[@"recordQuality"] integerValue];
    _recordQuality = (quality == 0)? RCChatroomSceneRecordQualityLow: RCChatroomSceneRecordQualityHigh;
       
    NSInteger position = [dic[@"recordPosition"] integerValue];
    _recordButtonPosition = (position == 0)? RCChatroomSceneRecordButtonPositionLeft: RCChatroomSceneRecordButtonPositionRight;
    return YES;
}

- (void)merge:(RCChatroomSceneToolBarConfig *)config {
    if (config == self) {
        return;
    }
    NSDictionary *propertyInfos = [YYClassInfo classInfoWithClass:[config class]].propertyInfos;
    [propertyInfos enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [config valueForKey:key];
//        NSLog(@"key:%@, value:%@, valueClass:%@",key,value, [value class]);
        if (value != nil) {
            [self setValue:value forKey:key];
        }
    }];
}
@end
