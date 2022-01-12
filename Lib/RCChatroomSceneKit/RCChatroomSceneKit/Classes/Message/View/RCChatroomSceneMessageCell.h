//
//  RCChatroomSceneMessageCell.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol
RCChatroomSceneMessageProtocol,
RCChatroomSceneEventProtocol;
@class RCChatroomSceneBubbleLayer,
RCChatroomSceneMessageViewConfig;
@interface RCChatroomSceneMessageCell : UITableViewCell

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) RCChatroomSceneBubbleLayer *bubbleLayer;

@property (nonatomic, weak) id<RCChatroomSceneMessageProtocol> message;
@property (nonatomic, weak) id<RCChatroomSceneEventProtocol> delegate;

- (instancetype)update:(id<RCChatroomSceneMessageProtocol>)message
              delegate:(id<RCChatroomSceneEventProtocol>)delegate config:(RCChatroomSceneMessageViewConfig *)config;

@end

@interface RCChatroomSceneMessageCell (Identifier)

+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
