//
//  RCChatroomSceneInputViewController.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatroomSceneInputViewControllerDelegate <NSObject>

- (void)inputViewDidClickSendButtonWith:(NSString *)content;

@end

@class RCChatroomSceneInputBarConfig;
@interface RCChatroomSceneInputViewController : UIViewController

- (instancetype)initWithConfig:(RCChatroomSceneInputBarConfig *)config
                 inputDelegate:(id<RCChatroomSceneInputViewControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
