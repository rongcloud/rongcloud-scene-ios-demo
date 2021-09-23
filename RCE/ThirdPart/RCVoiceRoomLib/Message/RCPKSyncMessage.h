//
//  RCPKSyncMessage.h
//  RCE
//
//  Created by 叶孤城 on 2021/8/17.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCPKSyncMessage : RCMessageContent

@property (nonatomic, copy) NSString *jsonString;

@end

NS_ASSUME_NONNULL_END
