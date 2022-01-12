//
//  RCChatroomAudioRecordView.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <UIKit/UIKit.h>

#import "RCChatroomSceneDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class RCChatroomSceneToolBarConfig;
@protocol RCChatroomAudioRecordViewDelegate <NSObject>

- (BOOL)audioRecordShouldBegin;
- (void)audioRecordDidBegin;
- (void)audioRecordDidCancel;
- (void)audioRecordDidEnd:(NSData *)data time:(NSTimeInterval)time;

@end

@interface RCChatroomAudioRecordView : UIView

@property (nonatomic, weak) id<RCChatroomAudioRecordViewDelegate> delegate;
@property (nonatomic, assign) RCChatroomAudioRecordState state;
@property (nonatomic, strong) RCChatroomSceneToolBarConfig *config;

- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END
