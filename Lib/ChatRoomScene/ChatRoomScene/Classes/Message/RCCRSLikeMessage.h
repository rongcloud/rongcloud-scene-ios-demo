//
//  RCMCLikeMessage.h
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRSLikeMessage : RCMessageContent

/// 点赞次数
@property (nonatomic, assign, readonly) NSUInteger count;

@end

NS_ASSUME_NONNULL_END
