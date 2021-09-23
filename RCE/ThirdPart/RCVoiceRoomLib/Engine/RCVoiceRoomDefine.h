//
//  RCVoiceRoomDefine.h
//  RCE
//
//  Created by shaoshuai on 2021/6/22.
//

#ifndef RCVoiceRoomDefine_h
#define RCVoiceRoomDefine_h

typedef NS_ENUM(NSUInteger, RCVoiceRoomAudioQuality) {
    /*!
     人声音质，编码码率最大值为32Kbps
     */
    RCVoiceRoomAudioQualitySpeech,
    /*!
     标清音乐音质，编码码率最大值为64Kbps
     */
    RCVoiceRoomAudioQualityMusic,
    /*!
     高清音乐音质，编码码率最大值为128Kbps
     */
    RCVoiceRoomAudioQualityMusicHigh,
};

/*!
 设置音频通话模式, 默认为普通通话模式 RCRTCAudioScenarioDefault
 */
typedef NS_ENUM(NSUInteger, RCVoiceRoomAudioScenario) {
    /*!
     普通通话模式(普通音质模式), 满足正常音视频场景
     */
    RCVoiceRoomAudioScenarioDefault,
    /*!
     音乐聊天室模式, 提升声音质量, 适用对音乐演唱要求较高的场景
     */
    RCVoiceRoomAudioScenarioMusicChatRoom,
    /*!
     音乐教室模式, 提升声音质量, 适用对乐器演奏音质要求较高的场景
     */
    RCVoiceRoomAudioScenarioMusicClassRoom,
};

#endif /* RCVoiceRoomDefine_h */
