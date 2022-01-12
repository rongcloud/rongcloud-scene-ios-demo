//
//  RCChatroomSceneMessageViewConfig.m
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/7.
//

#import "RCChatroomSceneMessageViewConfig.h"
#import "RCAttribute+Convert.h"
#import "RCChatroomSceneConfigHelper.h"

@implementation RCChatroomSceneMessageViewConfig
+ (instancetype)default {
    RCChatroomSceneMessageViewConfig *config = [RCChatroomSceneConfigHelper configFromJsonForClass:[self class]];
    if (config != nil) {
        return config;
    } else {
        return [self creatPrimaryConfig];
    }
}

+ (RCChatroomSceneMessageViewConfig *)creatPrimaryConfig {
    RCChatroomSceneMessageViewConfig *config = [[RCChatroomSceneMessageViewConfig alloc] init];
    config.contentInsets = UIEdgeInsetsZero;
    config.maxVisibleCount = 50;
    config.defaultBubbleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    config.bubbleInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    RCCorner *corner = [RCCorner new];
    corner.radius = 10;
    config.defaultBubbleCorner = corner;
    config.defaultBubbleTextColor = UIColor.whiteColor;
    config.bubbleSpace = 4;
    config.voiceIconColor = UIColor.whiteColor;
    return config;
}


- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _contentInsets = [RCInsets yy_modelWithJSON:dic[@"contentInsets"]].toUIEdgeInsets;
    _defaultBubbleColor = [RCColor yy_modelWithJSON:dic[@"defaultBubbleColor"]].toUIColor;
    _bubbleInsets = [RCInsets yy_modelWithJSON:dic[@"bubbleInsets"]].toUIEdgeInsets;
    _defaultBubbleTextColor = [RCColor yy_modelWithJSON:dic[@"defaultBubbleTextColor"]].toUIColor;
    _voiceIconColor = [RCColor yy_modelWithJSON:dic[@"voiceIconColor"]].toUIColor;
    _defaultBubbleCorner = [RCCorner yy_modelWithJSON:dic[@"defaultBubbleCorner"]];
    return YES;
}

- (void)merge:(RCChatroomSceneMessageViewConfig *)config {
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
