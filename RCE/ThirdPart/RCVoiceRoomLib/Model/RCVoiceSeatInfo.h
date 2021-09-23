//
//  RCSeatInfo.h
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 麦位状态是互斥的
typedef NS_ENUM(NSUInteger, RCSeatStatus) {
    RCSeatStatusEmpty = 0,
    RCSeatStatusUsing = 1,
    RCSeatStatusLocking = 2
};

@interface RCVoiceSeatInfo : NSObject<NSCopying>

/// 麦位状态，分为空置，有人使用，被锁定三种状态
@property (nonatomic, assign) RCSeatStatus status;

/// 是否静音
@property (nonatomic, assign, getter=isMuted) BOOL mute;

/// 若麦位被人使用，则userId为使用麦位的用户id
@property (nonatomic, copy, nullable) NSString *userId;

/// 其他信息
@property (nonatomic, copy, nullable) NSString *extra;

- (instancetype)init;

/// 类方法，根据jsonString生成一个RCVoiceSeatInfo实例
/// @param jsonSting RCVoiceSeatInfo的jsonSting
+ (RCVoiceSeatInfo *)modelWithJSON:(NSString *)jsonSting;

/// 自动生成该类对应的json字符串
- (NSString *)jsonString;

@end
NS_ASSUME_NONNULL_END
