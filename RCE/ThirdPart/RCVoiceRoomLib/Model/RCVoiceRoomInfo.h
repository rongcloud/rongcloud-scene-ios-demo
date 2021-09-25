//
//  RCVoiceRoomConfig.h
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomInfo : NSObject<NSCopying>

/// 房间名称，不可为空
@property (nonatomic, copy) NSString *roomName;

/// 房间麦位数量，不可为空
@property (nonatomic, assign) NSInteger seatCount;

/// 是否自由上麦
@property (nonatomic, assign) BOOL isFreeEnterSeat;

/// 房间麦位静音状态，状态标记，直接修改不会自动触发静音麦位操作
@property (nonatomic, assign) BOOL isMuteAll;

/// 房间麦位锁定状态，状态标记，直接修改不会自动触发锁麦操作
@property (nonatomic, assign) BOOL isLockAll;

/// 自定义属性，可以传入json等
@property (nonatomic, copy, nullable) NSString *extra;

- (instancetype)init;

/// 类方法，根据jsonString生成一个RCVoiceRoomInfo实例
/// @param jsonSting RCVoiceRoomInfo的jsonSting
+ (RCVoiceRoomInfo *)modelWithJSON:(NSString *)jsonSting;

/// 自动生成该类对应的json字符串
- (NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
