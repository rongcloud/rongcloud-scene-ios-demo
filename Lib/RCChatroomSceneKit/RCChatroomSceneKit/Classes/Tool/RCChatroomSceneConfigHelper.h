//
//  RCChatroomSceneConfigHelper.h
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/7.
//

#import <Foundation/Foundation.h>
#import "RCChatroomSceneToolBarConfig.h"
#import "RCChatroomSceneInputBarConfig.h"
#import "RCChatroomSceneMessageViewConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSceneConfigHelper : NSObject

+ (id)configFromJsonForClass:(Class)cls;
+ (id)configFromLocalPath:(NSString *)path forClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
