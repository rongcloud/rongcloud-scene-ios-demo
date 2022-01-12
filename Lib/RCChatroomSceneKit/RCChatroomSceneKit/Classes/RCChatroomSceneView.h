//
//  RCChatroomSceneView.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class
RCChatroomSceneMessageView,
RCChatroomSceneToolBar;

@interface RCChatroomSceneView : UIView

@property (nonatomic, readonly) RCChatroomSceneMessageView *messageView;
@property (nonatomic, readonly) RCChatroomSceneToolBar *toolBar;

@end

NS_ASSUME_NONNULL_END
