//
//  RCVoiceRoomRefreshMessage.h
//  RCE
//
//  Created by 叶孤城 on 2021/5/20.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCVoiceRoomRefreshMessage : RCMessageContent

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
