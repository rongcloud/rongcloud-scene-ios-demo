//
//  RCChatroomSceneDefine.h
//  Pods
//
//  Created by shaoshuai on 2021/11/1.
//

#ifndef RCChatroomSceneDefine_h
#define RCChatroomSceneDefine_h

typedef NS_ENUM(NSInteger, RCChatroomAudioRecordState) {
    RCChatroomAudioRecordStateIdle,
    RCChatroomAudioRecordStateBegin,
    RCChatroomAudioRecordStateRecording,
    RCChatroomAudioRecordStateOutArea,
    RCChatroomAudioRecordStateCancel,
    RCChatroomAudioRecordStateEnd,
    RCChatroomAudioRecordStateLack,
};


typedef NS_ENUM(NSInteger, RCChatroomSceneRecordButtonPosition) {
    RCChatroomSceneRecordButtonPositionLeft,
    RCChatroomSceneRecordButtonPositionRight,
};

typedef NS_ENUM(NSInteger, RCChatroomSceneRecordQuality) {
    RCChatroomSceneRecordQualityLow,
    RCChatroomSceneRecordQualityHigh,
};

#endif /* RCChatroomSceneDefine_h */
