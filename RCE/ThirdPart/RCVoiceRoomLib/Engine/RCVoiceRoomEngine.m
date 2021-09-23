//
//  RCVoiceRoomEngine.m
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/13.
//

#import "RCVoiceRoomEngine.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongChatRoom/RongChatRoom.h>
#import <RongRTCLib/RongRTCLib.h>
#import "RCVoiceSeatInfo.h"
#import "RCVoiceRoomInfo.h"
#import "RCVoiceRoomInviteMessage.h"
#import "RCVoiceRoomRefreshMessage.h"
#import "RCVoiceRoomDelegate.h"
#import "RCVoiceRoomConstants.h"
#import "RCVoiceRoomClient.h"
#import "RCVoiceRoomClientProtocol.h"
#import "RCVoicePKInfo.h"
#import "RCPKSyncMessage.h"

#define RCVoiceRoomSDkVersion @"2.0.0"

@interface RCVoiceRoomEngine()<RCRTCRoomEventDelegate, RCRTCOtherRoomEventDelegate, RCChatRoomKVStatusChangeDelegate, RCRTCStatusReportDelegate, RCIMClientReceiveMessageDelegate>

@property (nonatomic, weak, nullable) id<RCVoiceRoomDelegate> delegate;
@property (nonatomic, strong) NSHashTable* messageDelegateList;
@property (nonatomic, strong) RCRTCRoom *rtcRoom;
@property (nonatomic, assign) RCRTCLiveRoleType currentRole;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) RCVoiceRoomInfo *roomInfo;
@property (nonatomic, copy, readonly) NSString *currentUserId;
@property (nonatomic, strong) NSArray <RCVoiceSeatInfo *> *seatInfoList;
@property (nonatomic, strong) RCVoicePKInfo *currentPKInfo;
@end

@implementation RCVoiceRoomEngine
@synthesize currentUserId = _currentUserId;
+ (RCVoiceRoomEngine *)sharedInstance {
    static dispatch_once_t onceToken;
    static RCVoiceRoomEngine *engine;
    dispatch_once(&onceToken, ^{
        engine = [[RCVoiceRoomEngine alloc] init];
    });
    return engine;
}

- (instancetype)init {
    if (self = [super init]) {
        [self addNotification];
    }
    return self;
}

#pragma mark - Public Method

- (void)initWithAppkey:(NSString *)appKey {
#ifdef DEBUG
    [[RCCoreClient sharedCoreClient] setServerInfo:@"http://navqa.cn.ronghub.com" fileServer:@"upload.qiniup.com"];
#endif
    [[RCVoiceRoomClient client] initWithAppKey:appKey];
    [self delegateRedirect];
}

- (void)connectWithToken:(NSString *)appToken
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCVoiceRoomClient client] connectWithToken:appToken dbOpened:^(RCDBErrorCode code) {
        
    } success:^(NSString *userId) {
        successBlock();
    } error:^(RCConnectErrorCode errorCode) {
        errorBlock(RCVoiceRoomConnectTokenFailed, @"Init token failed");
    }];
}

- (NSString *)currentUserId {
    return RCCoreClient.sharedCoreClient.currentUserInfo.userId;
}

- (void)disconnect {
    [[RCVoiceRoomClient client] disconnect:true];
}

/// 代理重定向：外部可能抢占IM&RTC代理，考虑场景唯一性，暂时重新设置。
- (void)delegateRedirect {
    [[RCVoiceRoomClient client] setReceiveMessageDelegate:self];
    [[RCVoiceRoomClient client] registerMessageType:[RCVoiceRoomInviteMessage class]];
    [[RCVoiceRoomClient client] registerMessageType:[RCVoiceRoomRefreshMessage class]];
    [[RCVoiceRoomClient client] registerMessageType:[RCPKSyncMessage class]];
    [RCRTCEngine sharedInstance].statusReportDelegate = self;
    [[RCChatRoomClient sharedChatRoomClient] setRCChatRoomKVStatusChangeDelegate:self];
}

- (void)setDelegate:(id<RCVoiceRoomDelegate>)delegate {
    _delegate = delegate;
    [self delegateRedirect];
}

- (void)addMessageReceiveDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate {
    [self.messageDelegateList addObject:delegate];
    [self delegateRedirect];
}

- (void)removeMessageReceiveDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate {
    [self.messageDelegateList removeObject:delegate];
}

- (void)createAndJoinRoom:(NSString *)roomId
                     room:(RCVoiceRoomInfo *)roomInfo
                  success:(RCVoiceRoomSuccessBlock)successBlock
                    error:(RCVoiceRoomErrorBlock)errorBlock {
    if (self.currentUserId == nil || self.currentUserId.length == 0) {
        errorBlock(RCVoiceRoomUserIdIsEmpty, @"userId is Empty");
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.roomId = roomId;
    self.currentRole = RCRTCLiveRoleTypeAudience;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL isCreateSuccess = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RCChatRoomClient sharedChatRoomClient] joinChatRoom:roomId messageCount: -1 success:^{
            dispatch_semaphore_signal(semaphore);
        } error:^(RCErrorCode status) {
            isCreateSuccess = NO;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [weakSelf updateKvRoomInfo:roomInfo success:^{
            dispatch_semaphore_signal(semaphore);
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            isCreateSuccess = NO;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [weakSelf joinRTCRoom:roomId role:weakSelf.currentRole success:^{
            dispatch_semaphore_signal(semaphore);
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            isCreateSuccess = NO;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [weakSelf runMainQueue:^{
            if (isCreateSuccess) {
                weakSelf.roomInfo = roomInfo;
                [weakSelf initialSeatInfoListIfNeeded];
                if ([weakSelf.delegate respondsToSelector:@selector(roomInfoDidUpdate:)]) {
                    [weakSelf.delegate roomInfoDidUpdate:roomInfo];
                }
                if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                    [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
                }
                if ([weakSelf.delegate respondsToSelector:@selector(roomKVDidReady)]) {
                    [weakSelf.delegate roomKVDidReady];
                }
                successBlock();
            } else {
                errorBlock(RCVoiceRoomCreateRoomFailed, @"Create room failed");
            }
        }];
    });
}

- (void)joinRoom:(NSString *)roomId
         success:(RCVoiceRoomSuccessBlock)successBlock
           error:(RCVoiceRoomErrorBlock)errorBlock {
    if (self.currentUserId == nil || self.currentUserId.length == 0) {
        errorBlock(RCVoiceRoomUserIdIsEmpty, @"userId is Empty");
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.currentRole = RCRTCLiveRoleTypeAudience;
    self.roomId = roomId;
    [[RCChatRoomClient sharedChatRoomClient] joinChatRoom:roomId messageCount: -1 success:^{
        [weakSelf notifyVoiceRoom:RCAudienceJoinRoom content:self.currentUserId];
        [weakSelf joinRTCRoom:roomId role:weakSelf.currentRole success:^{
            [weakSelf changeUserRoleIfNeeded];
            successBlock();
        } error:errorBlock];
    } error:^(RCErrorCode status) {
        errorBlock(RCVoiceRoomJoinRoomFailed, @"Join ChatRoom Failed");
    }];
}

- (void)leaveRoom:(RCVoiceRoomSuccessBlock)successBlock
            error:(RCVoiceRoomErrorBlock)errorBlock {
    dispatch_group_t group = dispatch_group_create();
    __weak typeof(self) weakSelf = self;
    NSInteger userOnSeatIndex = [self seatIndexWhichUserSit:self.currentUserId];
    dispatch_group_enter(group);
    if (self.currentPKInfo != nil) {
        BOOL isAttender = ([self.currentUserId isEqualToString:self.currentPKInfo.inviterUserId] || [self.currentUserId isEqualToString:self.currentPKInfo.inviteeUserId]);
        if (isAttender) {
            [self quitPK:^{
                
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                
            }];
        }
    }
    if (userOnSeatIndex >= 0) {
        [self leaveSeatWithSuccess:^{
            dispatch_group_leave(group);
        } error:^(NSInteger code, NSString * _Nonnull msg) {
            dispatch_group_leave(group);
        }];
    } else {
        dispatch_group_leave(group);
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self notifyVoiceRoom:RCAudienceLeaveRoom content:self.currentUserId];
        if (self.roomId == nil) {
            successBlock();
            return;
        }
        [[RCChatRoomClient sharedChatRoomClient] quitChatRoom:self.roomId success:^{
            [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
                if (isSuccess) {
                    [weakSelf clearAll];
                    successBlock();
                } else {
                    errorBlock(RCVoiceRoomLeaveRoomFailed, @"Leave rtc room failed");
                }
            }];
        } error:^(RCErrorCode status) {
            errorBlock(RCVoiceRoomLeaveRoomFailed, @"Leave Chat room failed");
        }];
    });
}

- (void)enterSeat:(NSUInteger)seatIndex
          success:(RCVoiceRoomSuccessBlock)successBlock
            error:(RCVoiceRoomErrorBlock)errorBlock  {
    if (![self seatIndexInRange:seatIndex]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Seat index not correct");
        return;
    }
    RCVoiceSeatInfo *seatInfo = [self.seatInfoList[seatIndex] copy];
    if ([self.currentUserId isEqualToString:seatInfo.userId] && self.currentRole == RCRTCLiveRoleTypeAudience) {
        [self switchRole:RCRTCLiveRoleTypeBroadcaster success:^{
            successBlock();
        } error:errorBlock];
        return;
    }
    if (!(seatInfo.status == RCSeatStatusEmpty)) {
        errorBlock(RCVoiceRoomSeatNotEmpty, @"Seat is locked or using");
        return;
    }
    if ([self isUserOnSeat:self.currentUserId]) {
        errorBlock(RCVoiceRoomUserAlreadyOnSeat, @"User is on seat now");
        return;
    }
    seatInfo.userId = self.currentUserId;
    seatInfo.status = RCSeatStatusUsing;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:seatInfo seatIndex: seatIndex success:^{
        [weakSelf runMainQueue:^{
            [weakSelf replaceSeatWithIndex:seatIndex seatInfo:seatInfo];
            if ([weakSelf.delegate respondsToSelector:@selector(userDidEnterSeat:user:)]) {
                [weakSelf.delegate userDidEnterSeat:seatIndex user:weakSelf.currentUserId];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
        }];
        [weakSelf switchRole:RCRTCLiveRoleTypeBroadcaster success:successBlock error:errorBlock];
    } error: errorBlock];
}

- (void)leaveSeatWithSuccess:(RCVoiceRoomSuccessBlock)successBlock
                       error:(RCVoiceRoomErrorBlock)errorBlock {
    NSInteger seatIndex = [self seatIndexWhichUserSit:self.currentUserId];
    if (![self seatIndexInRange:seatIndex]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Seat index not correct");
        return;
    }
    RCVoiceSeatInfo *seatInfo = [self.seatInfoList[seatIndex] copy];
    seatInfo.userId = nil;
    seatInfo.status = RCSeatStatusEmpty;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:seatInfo seatIndex: seatIndex success:^{
        [weakSelf runMainQueue:^{
            [weakSelf replaceSeatWithIndex:seatIndex seatInfo:seatInfo];
            if ([weakSelf.delegate respondsToSelector:@selector(userDidLeaveSeat:user:)]) {
                [weakSelf.delegate userDidLeaveSeat:seatIndex user:weakSelf.currentUserId];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
        }];
        [weakSelf switchRole:RCRTCLiveRoleTypeAudience success:successBlock error:errorBlock];
    } error:errorBlock];
}

- (void)switchSeatTo:(NSUInteger)seatIndex
             success:(RCVoiceRoomSuccessBlock)successBlock
               error:(RCVoiceRoomErrorBlock)errorBlock {
    NSInteger previousIndex = [self seatIndexWhichUserSit:self.currentUserId];
    if (previousIndex < 0) {
        errorBlock(RCVoiceRoomUserNotOnSeat, @"User Not on seat now");
        return;
    }
    if (![self seatIndexInRange:seatIndex]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Target index not in range");
        return;
    }
    if (seatIndex == previousIndex) {
        errorBlock(RCVoiceRoomJumpIndexEqual, @"Target index can't equal to current index");
        return;
    }
    RCVoiceSeatInfo *previousSeatInfo = self.seatInfoList[previousIndex].copy;
    RCVoiceSeatInfo *targetSeatInfo = self.seatInfoList[seatIndex].copy;
    if (!(targetSeatInfo.status == RCSeatStatusEmpty)) {
        errorBlock(RCVoiceRoomSeatNotEmpty, @"Seat is locked or using");
        return;
    }
    previousSeatInfo.userId = nil;
    previousSeatInfo.status = RCSeatStatusEmpty;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:previousSeatInfo seatIndex: previousIndex success:^{
        [weakSelf runMainQueue:^{
            [weakSelf replaceSeatWithIndex:previousIndex seatInfo:previousSeatInfo];
            if ([weakSelf.delegate respondsToSelector:@selector(userDidLeaveSeat:user:)]) {
                [weakSelf.delegate userDidLeaveSeat:previousIndex user:weakSelf.currentUserId];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
        }];
    } error:errorBlock];
    targetSeatInfo.userId = self.currentUserId;
    targetSeatInfo.status = RCSeatStatusUsing;
    [self updateKvSeatInfo:targetSeatInfo seatIndex: seatIndex success:^{
        [weakSelf runMainQueue:^{
            [weakSelf replaceSeatWithIndex:seatIndex seatInfo:targetSeatInfo];
            if ([weakSelf.delegate respondsToSelector:@selector(userDidEnterSeat:user:)]) {
                [weakSelf.delegate userDidEnterSeat:seatIndex user:weakSelf.currentUserId];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
            [weakSelf muteSelfIfNeeded];
            successBlock();
        }];
    } error: errorBlock];
}

- (void)pickUserToSeat:(NSString *)userId
               success:(RCVoiceRoomSuccessBlock)successBlock
                 error:(RCVoiceRoomErrorBlock)errorBlock {
    if ([self isUserOnSeat:userId]) {
        errorBlock(RCVoiceRoomUserAlreadyOnSeat, @"User alredy on seat");
        return;
    }
    if ([self.currentUserId isEqualToString:userId]) {
        errorBlock(RCVoiceRoomPickSelfToSeat, @"User can't pick self on seat");
        return;
    }
    NSString *uuid = [[NSUUID UUID] UUIDString];
    RCVoiceRoomInviteMessage *message = [[RCVoiceRoomInviteMessage alloc] init];
    message.sendUserId = self.currentUserId;
    message.type = RCVoiceRoomInviteTypeRequest;
    message.content = RCPickerUserSeatContent;
    message.invitationId = uuid;
    message.targetId = userId;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:message success:^(long messageId) {
        successBlock();
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomPickUserFailed, @"Pick user seat failed");
    }];
}

- (void)getLatestSeatInfo:(void (^)(NSArray<RCVoiceSeatInfo *>*))successBlock
                    error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:self.roomId success:^(NSDictionary * _Nonnull entry) {
        NSArray *list = [self latestMicInfoListFromEntry:entry];
        successBlock(list);
    } error:^(RCErrorCode nErrorCode) {
        errorBlock(RCVoiceRoomGetLatestSeatInfoFailed, @"Get SeatInfo failed");
    }];
}

- (void)kickUserFromSeat:(NSString *)userId
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    NSInteger userSeatIndex = [self seatIndexWhichUserSit: userId];
    if (userSeatIndex < 0) {
        errorBlock(RCVoiceRoomUserNotOnSeat, @"User not on seat");
        return;
    }
    if ([self.currentUserId isEqualToString:userId]) {
        errorBlock(RCVoiceRoomUserKickSelfFromSeat, @"User can't kick self");
        return;
    }
    RCVoiceSeatInfo *seatInfo = self.seatInfoList[userSeatIndex].copy;
    seatInfo.status = RCSeatStatusEmpty;
    seatInfo.userId = nil;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:seatInfo seatIndex: userSeatIndex success:^{
        [weakSelf runMainQueue:^{
            [weakSelf replaceSeatWithIndex:userSeatIndex seatInfo:seatInfo];
            if ([weakSelf.delegate respondsToSelector:@selector(userDidLeaveSeat:user:)]) {
                [weakSelf.delegate userDidLeaveSeat:userSeatIndex user:userId];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
            successBlock();
        }];
    } error:errorBlock];
}

- (void)kickUserFromRoom:(NSString *)userId
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    NSString *uuid = [[NSUUID UUID] UUIDString];
    RCVoiceRoomInviteMessage *message = [[RCVoiceRoomInviteMessage alloc] init];
    message.sendUserId = self.currentUserId;
    message.type = RCVoiceRoomInviteTypeRequest;
    message.content = RCKickUserOutRoomContent;
    message.invitationId = uuid;
    message.targetId = userId;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:message success:^(long messageId) {
        [weakSelf runMainQueue:^{
            if ([weakSelf.delegate respondsToSelector:@selector(userDidKickFromRoom:byUserId:)]) {
                [weakSelf.delegate userDidKickFromRoom:userId byUserId:weakSelf.currentUserId];
            }
            successBlock();
        }];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(RCVoiceRoomPickUserFailed, @"Pick user seat failed");
        });
    }];
}

- (void)requestSeat:(RCVoiceRoomSuccessBlock)successBlock
              error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:self.roomId success:^(NSDictionary * _Nonnull entry) {
        NSMutableArray *requestKeys = [NSMutableArray array];
        for (NSString *key in entry.allKeys) {
            if ([key containsString:self.currentUserId] && [entry[key] isEqualToString:RCRequestSeatContentRequest]) {
                errorBlock(RCVoiceRoomAlreadyInRequestList, @"User already on seat");
                return;;
            }
            if ([key hasPrefix:RCRequestSeatPrefixKey]) {
                [requestKeys addObject:key];
            }
        }
        if (requestKeys.count > 20) {
            errorBlock(RCVoiceRoomRequestListFull, @"Request seat list is full, the max is 20");
            return;
        }
        [self updateRequestSeatKvWithUserID:self.currentUserId content:RCRequestSeatContentRequest success:successBlock error:errorBlock];
    } error:^(RCErrorCode nErrorCode) {
        errorBlock(RCVoiceRoomSendRequestSeatFailed, @"Send request seat failed");
    }];
}

- (void)cancelRequestSeat:(RCVoiceRoomSuccessBlock)successBlock
                    error:(RCVoiceRoomErrorBlock)errorBlock {
    [RCChatRoomClient.sharedChatRoomClient removeChatRoomEntry:self.roomId key:[self RequestSeatKvKey:self.currentUserId] sendNotification:NO notificationExtra:@"" success:successBlock error:^(RCErrorCode nErrorCode) {
        errorBlock(RCVoiceRoomCancelRequestSeatFailed, @"Cancel request seat failed");
    }];
}

- (void)acceptRequestSeat:(NSString *)userId
                  success:(RCVoiceRoomSuccessBlock)successBlock
                    error:(RCVoiceRoomErrorBlock)errorBlock {
    [self updateRequestSeatKvWithUserID:userId content:RCRequestSeatContentAccept success:successBlock error:errorBlock];
}

- (void)rejectRequestSeat:(NSString *)userId
                  success:(RCVoiceRoomSuccessBlock)successBlock
                    error:(RCVoiceRoomErrorBlock)errorBlock {
    [self updateRequestSeatKvWithUserID:userId content:RCRequestSeatContentDeny success:successBlock error:errorBlock];
}

- (void)getRequestSeatUserIds:(void (^)(NSArray<NSString *>*))successBlock
                        error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:self.roomId success:^(NSDictionary * _Nonnull entry) {
        NSMutableArray *userlist = [NSMutableArray array];
        for (NSString *key in entry.allKeys) {
            if ([key hasPrefix:RCRequestSeatPrefixKey]) {
                NSArray *list = [key componentsSeparatedByString:@"_"];
                if (list.count == 2 && [entry[key] isEqualToString:RCRequestSeatContentRequest]) {
                    [userlist addObject:list[1]];
                }
            }
        }
        successBlock(userlist);
    } error:^(RCErrorCode nErrorCode) {
        errorBlock(RCVoiceRoomGetRequestListFailed, @"Get entries failed");
    }];
}

- (void)lockSeat:(NSUInteger)seatIndex
            lock:(BOOL)isLocked
         success:(RCVoiceRoomSuccessBlock)successBlock
           error:(RCVoiceRoomErrorBlock)errorBlock {
    if (![self seatIndexInRange:seatIndex]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Seat index not correct");
        return;
    }
    RCVoiceSeatInfo *seatInfo = [self.seatInfoList[seatIndex] copy];
    if (isLocked) {
        seatInfo.status = RCSeatStatusLocking;
    } else {
        seatInfo.status = RCSeatStatusEmpty;
    }
    seatInfo.userId = nil;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:seatInfo seatIndex: seatIndex success:^{
        [weakSelf replaceSeatWithIndex:seatIndex seatInfo:seatInfo];
        [weakSelf runMainQueue:^{
            if ([weakSelf.delegate respondsToSelector:@selector(seatDidLock:isLock:)]) {
                [weakSelf.delegate seatDidLock:seatIndex isLock:isLocked];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
            successBlock();
        }];
    } error: errorBlock];
    
}

- (void)muteSeat:(NSUInteger)seatIndex
            mute:(BOOL)isMute
         success:(RCVoiceRoomSuccessBlock)successBlock
           error:(RCVoiceRoomErrorBlock)errorBlock {
    if (![self seatIndexInRange:seatIndex]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Seat index not correct");
        return;
    }
    RCVoiceSeatInfo *seatInfo = [self.seatInfoList[seatIndex] copy];
    seatInfo.mute = isMute;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:seatInfo seatIndex: seatIndex success:^{
        [weakSelf replaceSeatWithIndex:seatIndex seatInfo:seatInfo];
        [weakSelf runMainQueue:^{
            [weakSelf muteSelfIfNeeded];
            if ([weakSelf.delegate respondsToSelector:@selector(seatDidMute:isMute:)]) {
                [weakSelf.delegate seatDidMute:seatIndex isMute:isMute];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
                [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
            }
        }];
        successBlock();
    } error: errorBlock];
}

- (void)muteOtherSeats:(BOOL)isMute {
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < self.seatInfoList.count; i++) {
        RCVoiceSeatInfo *seatInfo = [self.seatInfoList[i] copy];
        if (![self seatIndexInRange:i]) {
            continue;
        }
        if(seatInfo.userId != nil && [self.currentUserId isEqualToString:seatInfo.userId]) {
            continue;
        }
        seatInfo.mute = isMute;
        __weak typeof(self) weakSelf = self;
        dispatch_group_enter(group);
        [self updateKvSeatInfo:seatInfo seatIndex: i success:^{
            [weakSelf replaceSeatWithIndex:i seatInfo:seatInfo];
            [weakSelf runMainQueue:^{
                [weakSelf muteSelfIfNeeded];
            }];
            dispatch_group_leave(group);
        } error:^(NSInteger code, NSString *msg) {
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
            [self.delegate seatInfoDidUpdate:self.seatInfoList];
        }
        RCVoiceRoomInfo *room = self.roomInfo.copy;
        room.isMuteAll = isMute;
        [self setRoomInfo:room success:^{
            
        } error:^(NSInteger code, NSString * _Nonnull msg) {
            
        }];
    });
}

- (void)muteAllRemoteStreams:(BOOL)isMute {
    [self.rtcRoom muteAllRemoteAudio:isMute];
}

- (void)lockOtherSeats:(BOOL)isLock {
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < self.seatInfoList.count; i++) {
        if (![self seatIndexInRange:i]) {
            continue;
        }
        RCVoiceSeatInfo *seatInfo = [self.seatInfoList[i] copy];
        if (seatInfo.userId != nil && [seatInfo.userId isEqualToString:self.currentUserId]) {
            continue;
        }
        if (seatInfo.status == RCSeatStatusUsing || seatInfo.userId != nil) {
            continue;
        }
        if (isLock) {
            seatInfo.status = RCSeatStatusLocking;
        } else {
            seatInfo.status = RCSeatStatusEmpty;
        }
        dispatch_group_enter(group);
        __weak typeof(self) weakSelf = self;
        [self updateKvSeatInfo:seatInfo seatIndex: i success:^{
            [weakSelf replaceSeatWithIndex:i seatInfo:seatInfo];
            dispatch_group_leave(group);
        } error:^(NSInteger code, NSString * _Nonnull msg) {
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
            [self.delegate seatInfoDidUpdate:self.seatInfoList];
        }
        RCVoiceRoomInfo *room = self.roomInfo.copy;
        room.isLockAll = isLock;
        [self setRoomInfo:room success:^{
            
        } error:^(NSInteger code, NSString * _Nonnull msg) {
            
        }];
    });
}

- (void)sendMessage:(RCMessageContent *)message
            success:(RCVoiceRoomSuccessBlock)successBlock
              error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCVoiceRoomClient client] sendMessage:_roomId content:message success:^(long messageId) {
        successBlock();
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomSendMessageFailed, @"Send message failed");
    }];
}

- (void)notifyVoiceRoom:(NSString *)name content:(NSString *)content {
    RCVoiceRoomRefreshMessage *refreshMessage = [[RCVoiceRoomRefreshMessage alloc] init];
    refreshMessage.name = name;
    refreshMessage.content = content;
    [self sendMessage:refreshMessage success:^{
        
    } error:^(NSInteger code, NSString * _Nonnull msg) {
        
    }];
}

- (void)setRoomInfo:(RCVoiceRoomInfo *)roomInfo
            success:(RCVoiceRoomSuccessBlock)successBlock
              error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    NSArray *seatInfolist = self.seatInfoList.copy;
    if (roomInfo.seatCount != self.roomInfo.seatCount) {
        roomInfo.isMuteAll = false;
        roomInfo.isLockAll = false;
        seatInfolist = [weakSelf resetListExceptOwnerSeat:roomInfo.seatCount];
    }
    [self updateKvRoomInfo:roomInfo success:^{
        weakSelf.roomInfo = roomInfo;
        weakSelf.seatInfoList = seatInfolist;
        if ([weakSelf.delegate respondsToSelector:@selector(roomInfoDidUpdate:)]) {
            [weakSelf.delegate roomInfoDidUpdate:weakSelf.roomInfo.copy];
            
        }
        if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
            [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
        }
        successBlock();
    } error:errorBlock];
}

- (void)disableAudioRecording:(BOOL)isDisable {
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:isDisable];
}

- (void)enableSpeaker:(BOOL)isEnable {
    [[RCRTCEngine sharedInstance] enableSpeaker:isEnable];
}

- (void)setAudioQuality:(RCVoiceRoomAudioQuality)quality scenario:(RCVoiceRoomAudioScenario)scenario {
    RCRTCAudioQuality audioQuality = RCRTCAudioQualitySpeech;
    switch (quality) {
        case RCVoiceRoomAudioQualitySpeech:
            audioQuality = RCRTCAudioQualitySpeech;
            break;;
        case RCVoiceRoomAudioQualityMusic:
            audioQuality = RCRTCAudioQualityMusic;
            break;
        case RCVoiceRoomAudioQualityMusicHigh:
            audioQuality = RCRTCAudioQualityMusicHigh;
    }
    RCRTCAudioScenario audioScenario = RCRTCAudioScenarioDefault;
    switch (scenario) {
        case RCVoiceRoomAudioScenarioDefault:
            audioScenario = RCRTCAudioScenarioDefault;
            break;
        case RCVoiceRoomAudioScenarioMusicChatRoom:
            audioScenario = RCRTCAudioScenarioMusicChatRoom;
            break;
        case RCVoiceRoomAudioScenarioMusicClassRoom:
            audioScenario = RCRTCAudioScenarioMusicClassRoom;
    }
    [[[RCRTCEngine sharedInstance] defaultAudioStream] setAudioQuality:audioQuality Scenario:audioScenario];
}

- (void)sendInvitation:(NSString *)content
               success:(void (^)(NSString *))successBlock
                 error:(RCVoiceRoomErrorBlock)errorBlock {
    RCVoiceRoomInviteMessage *inviteMessage = [[RCVoiceRoomInviteMessage alloc] init];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    inviteMessage.invitationId = uuid;
    inviteMessage.sendUserId = self.currentUserId;
    inviteMessage.type = RCVoiceRoomInviteTypeRequest;
    inviteMessage.content = content;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:inviteMessage success:^(long messageId) {
        successBlock(uuid);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomSendInvitationSeatFailed, @"send invitation failed");
    }];
}

- (void)rejectInvitation:(NSString *)invitationId
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    RCVoiceRoomInviteMessage *inviteMessage = [[RCVoiceRoomInviteMessage alloc] init];
    inviteMessage.invitationId = invitationId;
    inviteMessage.sendUserId = self.currentUserId;
    inviteMessage.type = RCVoiceRoomInviteTypeReject;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:inviteMessage success:^(long messageId) {
        successBlock();
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomRejectInvitationFailed, @"reject invitation failed");
    }];
}

- (void)acceptInvitation:(NSString *)invitationId
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    RCVoiceRoomInviteMessage *inviteMessage = [[RCVoiceRoomInviteMessage alloc] init];
    inviteMessage.invitationId = invitationId;
    inviteMessage.sendUserId = self.currentUserId;
    inviteMessage.type = RCVoiceRoomInviteTypeAccept;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:inviteMessage success:^(long messageId) {
        successBlock();
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomAcceptInvitationFailed, @"accept invitation failed");
    }];
}

- (void)cancelInvitation:(NSString *)invitationId
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    RCVoiceRoomInviteMessage *inviteMessage = [[RCVoiceRoomInviteMessage alloc] init];
    inviteMessage.invitationId = invitationId;
    inviteMessage.sendUserId = self.currentUserId;
    inviteMessage.type = RCVoiceRoomInviteTypeCancel;
    [[RCVoiceRoomClient client] sendMessage:_roomId content:inviteMessage success:^(long messageId) {
        successBlock();
    } error:^(RCErrorCode nErrorCode, long messageId) {
        errorBlock(RCVoiceRoomCancelInvitationFailed, @"cancel invitation failed");
    }];
}

- (void)inviteUserAttendPKFromRoom:(NSString *)roomId
                          withUser:(NSString *)userId
                           success:(RCVoiceRoomSuccessBlock)successBlock
                             error:(RCVoiceRoomErrorBlock)errorBlock {
    [self.rtcRoom.localUser requestJoinOtherRoom:roomId userId:userId autoMix:true extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess) {
            successBlock();
        } else {
            errorBlock(RCVoiceRoomSendPKInviteFaild, @"send pk invite failed");
        }
    }];
}

- (void)cancelPKInviteFromRoom:(NSString *)roomId
                      withUser:(NSString *)userId
                       success:(RCVoiceRoomSuccessBlock)successBlock
                         error:(RCVoiceRoomErrorBlock)errorBlock {
    [self.rtcRoom.localUser cancelRequestJoinOtherRoom:roomId userId:userId extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess) {
            successBlock();
        } else {
            errorBlock(RCVoiceRoomCancelPKFailed, @"cancel pk request failed");
        }
    }];
}

- (void)responsePKInviteFromRoom:(NSString *)roomId
                         inviter:(NSString *)userId
                          agree:(BOOL)isAgree
                        success:(RCVoiceRoomSuccessBlock)successBlock
                          error:(RCVoiceRoomErrorBlock)errorBlock{
    __weak typeof(self) weakSelf = self;
    [self.rtcRoom.localUser responseJoinOtherRoom:roomId userId:userId agree:isAgree autoMix:YES extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {
        [self runMainQueue:^{
            if (isSuccess) {
                [weakSelf beginPKWithInviter:userId inviterRoom:roomId invitee:self.currentUserId inviteeRoom:self.roomId success:^{
                    successBlock();
                } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                    errorBlock(RCVoiceRoomBeginPKFailed, @"join other room failed");
                }];
            } else {
                errorBlock(RCVoiceRoomBeginPKFailed, @"response to join pk failed");
            }
        }];
    }];
}

- (void)quitPK:(RCVoiceRoomSuccessBlock)successBlock
         error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    if (self.currentPKInfo != nil) {
        NSString *otherRoomId = self.currentPKInfo.inviterRoomId;
        if ([otherRoomId isEqualToString:self.roomId]) {
            otherRoomId = self.currentPKInfo.inviteeRoomId;
        }
        [[RCRTCEngine sharedInstance] leaveOtherRoom:otherRoomId notifyFinished:YES completion:^(BOOL isSuccess, RCRTCCode code) {
            [weakSelf runMainQueue:^{
                if (isSuccess) {
                    NSLog(@"leave other room success");
                    self.currentPKInfo = nil;
                    if ([self.delegate respondsToSelector:@selector(pkDidFinish)]) {
                        [self.delegate pkDidFinish];
                    }
                    successBlock();
                } else {
                    NSLog(@"leave other room failed");
                    errorBlock(RCVoiceRoomQuitPKFailed, @"quit pk failed");
                }
            }];
        }];
        [self forceRemoveKV:RCVoiceRoomPKInfoKey];
    }
}

- (void)updateSeatInfo:(NSUInteger)index
             withExtra:(NSString *)extra
               success:(RCVoiceRoomSuccessBlock)successBlock
                 error:(RCVoiceRoomErrorBlock)errorBlock {
    if (![self seatIndexInRange:index]) {
        errorBlock(RCVoiceRoomSeatIndexOutOfRange, @"Index out of range");
        return;
    }
    RCVoiceSeatInfo *info = self.seatInfoList[index].copy;
    info.extra = extra;
    __weak typeof(self) weakSelf = self;
    [self updateKvSeatInfo:info seatIndex:index success:^{
        [weakSelf replaceSeatWithIndex:index seatInfo:info];
        if ([weakSelf.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
            [weakSelf.delegate seatInfoDidUpdate:weakSelf.seatInfoList];
        }
        successBlock();
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        errorBlock(RCVoiceRoomSyncSeatInfoFailed, @"Update Seat Info failed");
    }];
}

#pragma mark - RCRTCStatusReportDelegate

- (void)didReportStatusForm:(RCRTCStatusForm *)form {
    __weak typeof(self) weakSelf = self;
    [self runMainQueue:^{
        if ([weakSelf.delegate respondsToSelector:@selector(networkStatus:)]) {
            [weakSelf.delegate networkStatus:form.rtt];
        }
    }];
    NSInteger userSeatIndex = [self seatIndexWhichUserSit:self.currentUserId];
    if (userSeatIndex >= 0) {
        for (RCRTCStreamStat *status in form.sendStats) {
            if ([status.mediaType isEqualToString:RongRTCMediaTypeAudio]) {
                NSString *speaking = @"0";
                if (status.audioLevel > 0) {
                    speaking = @"1";
                } else {
                    speaking = @"0";
                }
                [self notifyVoiceRoom:[self speakingKey:userSeatIndex] content:speaking];
                [self runMainQueue:^{
                    if ([weakSelf.delegate respondsToSelector:@selector(speakingStateDidChange:speakingState:)]) {
                        [weakSelf.delegate speakingStateDidChange:userSeatIndex speakingState:[speaking isEqualToString:@"1"]];
                    }
                }];
                break;
            }
        }
    }
}

#pragma mark - RCRTCRoomEventDelegate

- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    if (self.rtcRoom != nil && self.currentRole == RCRTCLiveRoleTypeBroadcaster) {
        [self.rtcRoom.localUser subscribeStream:streams tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {
            
        }];
    }
}

- (void)didPublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    if (self.rtcRoom != nil && self.currentRole == RCRTCLiveRoleTypeAudience) {
        [self.rtcRoom.localUser subscribeStream:streams tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {
            
        }];
    }
}

- (void)didPublishCDNStream:(RCRTCCDNInputStream *)stream {
    
}

#pragma mark - PK Delegate
- (void)didFinishOtherRoom:(NSString *)roomId userId:(NSString *)userId {
    NSLog(@"receive pk user finish");
    [self quitPK:^{
        
    } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
        
    }];
}

- (void)didRequestJoinOtherRoom:(NSString *)inviterRoomId inviterUserId:(NSString *)inviterUserId extra:(NSString *)extra {
    __weak typeof(self) weakSelf = self;
    [self runMainQueue:^{
        if ([weakSelf.delegate respondsToSelector:@selector(pkInviteDidReceiveFromRoom:byUser:)]) {
            [weakSelf.delegate pkInviteDidReceiveFromRoom:inviterRoomId byUser:inviterUserId];
        }
    }];
}

- (void)didCancelRequestOtherRoom:(NSString *)inviterRoomId inviterUserId:(NSString *)inviterUserId extra:(NSString *)extra {
    __weak typeof(self) weakSelf = self;
    [self runMainQueue:^{
        if ([weakSelf.delegate respondsToSelector:@selector(cancelPKInviteDidReceiveFromRoom:byUser:)]) {
            [weakSelf.delegate cancelPKInviteDidReceiveFromRoom:inviterRoomId byUser:inviterUserId];
        }
    }];
}

- (void)didResponseJoinOtherRoom:(NSString *)inviterRoomId inviterUserId:(NSString *)inviterUserId inviteeRoomId:(NSString *)inviteeRoomId inviteeUserId:(NSString *)inviteeUserId agree:(BOOL)agree extra:(NSString *)extra {
    NSLog(@"receive pk user response");
    if ([self.currentUserId isEqualToString:inviterUserId]) {
        __weak typeof(self) weakSelf = self;
        if (agree) {
            [self beginPKWithInviter:inviterUserId inviterRoom:inviterRoomId invitee:inviteeUserId inviteeRoom:inviteeRoomId success:^{
                
            } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
                
            }];
            
        } else {
            [self runMainQueue:^{
                if ([weakSelf.delegate respondsToSelector:@selector(rejectPKInviteDidReceiveFromRoom:byUser:)]) {
                    [weakSelf.delegate rejectPKInviteDidReceiveFromRoom:inviteeRoomId byUser:inviteeUserId];
                }
            }];
        }
    }
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    __weak typeof(self) weakSelf = self;
    if ([self ifCouldTransfer:message]) {
        for (id<RCIMClientReceiveMessageDelegate> delegate in self.messageDelegateList) {
            if ([delegate respondsToSelector:@selector(onReceived:left:object:)]) {
                [delegate onReceived:message left:nLeft object:object];
            }
        }
        if ([self.delegate respondsToSelector:@selector(messageDidReceive:)]) {
            [self.delegate messageDidReceive:message];
        }
    } else {
        [self runMainQueue:^{
            [weakSelf handleInvitationMessage:message];
            [weakSelf handleRefreshMessage:message];
        }];
    }
}

#pragma mark - RCChatRoomKVStatusChangeDelegate
- (void)chatRoomKVDidSync:(NSString *)roomId {}

- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    NSLog(@"entry is %@", entry);
    __weak typeof(self) weakSelf = self;
    [self runMainQueue:^{
        [weakSelf updateRoomInfoFromEntry:entry];
        [weakSelf initialSeatInfoListIfNeeded];
        [weakSelf updateSeatInfoFromEntry:entry];
        [weakSelf handleRequestSeatKvUpdated:entry];
        [weakSelf handlePKUpdated:entry];
    }];
}

- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    __weak typeof(self) weakSelf = self;
    [self runMainQueue:^{
        [weakSelf handleRequestSeatCancelled:entry];
        [weakSelf handlePKRemoved:entry];
    }];
}

#pragma mark - Getter & Setter
- (NSHashTable *)messageDelegateList {
    if (!_messageDelegateList) {
        _messageDelegateList = [NSHashTable weakObjectsHashTable];
    }
    return _messageDelegateList;
}

#pragma mark - Private Method

- (void)beginPKWithInviter:(NSString *)inviterId
               inviterRoom:(NSString *)inviterRoomId
                   invitee:(NSString *)inviteeId
             inviteeRoom:(NSString *)inviteeRoomId
                success:(RCVoiceRoomSuccessBlock)successBlock
                  error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    NSString *joinRoomId = [inviterRoomId isEqualToString:self.roomId] ? inviteeRoomId : inviterRoomId;
    [[RCRTCEngine sharedInstance] joinOtherRoom:joinRoomId
                                     completion:^(RCRTCOtherRoom * _Nullable pkRoom, RCRTCCode code) {
        pkRoom.delegate = self;
        if (code == RCRTCCodeSuccess) {
            self.currentPKInfo = [[RCVoicePKInfo alloc] initWithInviterId:inviterId inviterRoomId:inviterRoomId inviteeId:inviteeId inviteeRoomId:inviteeRoomId];
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in pkRoom.remoteUsers) {
                for (RCRTCInputStream *stream in user.remoteStreams) {
                    [streamArray addObject:stream];
                }
            }

            if (streamArray.count > 0) {
                [self.rtcRoom.localUser subscribeStream:streamArray
                                                tinyStreams:@[]
                                                 completion:^(BOOL isSuccess, RCRTCCode desc) {
                }];
            }
            [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:weakSelf.roomId key:RCVoiceRoomPKInfoKey value:[self.currentPKInfo jsonString] sendNotification:false autoDelete:true notificationExtra:@"" success:^{
                
            } error:^(RCErrorCode nErrorCode) {
                
            }];
            [weakSelf runMainQueue:^{
                if ([weakSelf.delegate respondsToSelector:@selector(pkOngoingWithInviterRoom:withInviterUserId:withInviteeRoom:withInviteeUserId:)]) {
                    [weakSelf.delegate pkOngoingWithInviterRoom:self.currentPKInfo.inviterRoomId withInviterUserId:self.currentPKInfo.inviterUserId withInviteeRoom:self.currentPKInfo.inviteeRoomId withInviteeUserId:self.currentPKInfo.inviteeUserId];
                }
                successBlock();
            }];
            
        } else {
            NSLog(@"join other room failed, %d", code);
            errorBlock(RCVoiceRoomBeginPKFailed, @"begin pk failed");
        }
    }];
}

- (void)syncPKInfo:(NSString *)jsonString {
    RCPKSyncMessage *syncMessage = [[RCPKSyncMessage alloc] init];
    syncMessage.jsonString = jsonString;
#warning not finished
}

- (void)handleInvitationMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCVoiceRoomInviteMessage class]]) {
        if (message.conversationType == ConversationType_CHATROOM && [message.targetId isEqualToString:self.roomId]) {
            RCVoiceRoomInviteMessage *inviteMessage = (RCVoiceRoomInviteMessage *)message.content;
            switch (inviteMessage.type) {
                case RCVoiceRoomInviteTypeRequest:
                    if ([inviteMessage.content isEqualToString:RCPickerUserSeatContent] && [inviteMessage.targetId isEqualToString:self.currentUserId]) {
                        if ([self.delegate respondsToSelector:@selector(pickSeatDidReceiveBy:)]) {
                            [self.delegate pickSeatDidReceiveBy:inviteMessage.sendUserId];
                        }
                        break;
                    }
                    if ([inviteMessage.content isEqualToString:RCKickUserOutRoomContent]) {
                        if ([self.delegate respondsToSelector:@selector(userDidKickFromRoom:byUserId:)]) {
                            [self.delegate userDidKickFromRoom:inviteMessage.targetId byUserId:inviteMessage.sendUserId];
                        }
                        break;
                    }
                    if ([self.delegate respondsToSelector:@selector(invitationDidReceive:from:content:)]) {
                        [self.delegate invitationDidReceive:inviteMessage.invitationId from:inviteMessage.sendUserId content:inviteMessage.content];
                        break;
                    }
                    break;
                case RCVoiceRoomInviteTypeAccept:
                    if ([self.delegate respondsToSelector:@selector(invitationDidAccept:)]) {
                        [self.delegate invitationDidAccept:inviteMessage.invitationId];
                    }
                    break;
                case RCVoiceRoomInviteTypeReject:
                    if ([self.delegate respondsToSelector:@selector(invitationDidReject:)]) {
                        [self.delegate invitationDidReject:inviteMessage.invitationId];
                    }
                    break;
                case RCVoiceRoomInviteTypeCancel:
                    if ([self.delegate respondsToSelector:@selector(invitationDidCancel:)]) {
                        [self.delegate invitationDidCancel:inviteMessage.invitationId];
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)handleRefreshMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCVoiceRoomRefreshMessage class]]) {
        if (message.conversationType == ConversationType_CHATROOM && [message.targetId isEqualToString:self.roomId]) {
            RCVoiceRoomRefreshMessage *refreshMessage = (RCVoiceRoomRefreshMessage *)message.content;
            if ([refreshMessage.name isEqualToString:RCAudienceJoinRoom]) {
                if ([self.delegate respondsToSelector:@selector(userDidEnter:)]) {
                    [self.delegate userDidEnter:refreshMessage.content];
                }
            } else if ([refreshMessage.name isEqualToString:RCAudienceLeaveRoom]) {
                if ([self.delegate respondsToSelector:@selector(userDidExit:)]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.delegate userDidExit:refreshMessage.content];
                    });
                }
            }
            if ([refreshMessage.name containsString:RCUserOnSeatSpeakingKey]) {
                NSArray *list = [refreshMessage.name componentsSeparatedByString:@"_"];
                if (list.count == 2) {
                    NSInteger seatIndex = [list[1] integerValue];
                    if ([self seatIndexInRange:seatIndex] && [self.delegate respondsToSelector:@selector(speakingStateDidChange:speakingState:)]) {
                        [self.delegate speakingStateDidChange:seatIndex speakingState:[refreshMessage.content isEqualToString:@"1"]];
                    }
                }
            }
            if ([self.delegate respondsToSelector:@selector(roomNotificationDidReceive:content:)]) {
                [self.delegate roomNotificationDidReceive:refreshMessage.name content:refreshMessage.content];
            }
        }
    }
}

- (BOOL)ifCouldTransfer:(RCMessage *)message {
    return !([message.content isKindOfClass:[RCVoiceRoomRefreshMessage class]] || [message.content isKindOfClass:[RCVoiceRoomInviteMessage class]]);
}

- (NSString *)seatInfoSeatPartKvKey:(NSUInteger)index {
    return [NSString stringWithFormat:@"%@_%lu", RCSeatInfoSeatPartPrefixKey, (unsigned long)index];
}

- (NSString *)speakingKey:(NSUInteger)index {
    return [NSString stringWithFormat:@"%@_%lu", RCUserOnSeatSpeakingKey, (unsigned long)index];
}

- (NSString *)RequestSeatKvKey:(NSString *)content {
    return [NSString stringWithFormat:@"%@_%@", RCRequestSeatPrefixKey, content];
}

- (void)updateRoomInfoFromEntry:(NSDictionary<NSString *,NSString *> *)entry {
    if ([entry.allKeys containsObject:RCRoomInfoKey]) {
        NSString *infoJSONString = entry[RCRoomInfoKey];
        RCVoiceRoomInfo *info = [RCVoiceRoomInfo modelWithJSON:infoJSONString];
        self.roomInfo = info;
        if ([self.delegate respondsToSelector:@selector(roomInfoDidUpdate:)]) {
            [self.delegate roomInfoDidUpdate:info.copy];
        }
        NSCAssert(info != nil, @"init room info errora");
    }
}

- (void)updateSeatInfoFromEntry:(NSDictionary<NSString *,NSString *> *)entry {
    NSMutableArray *oldMutableList = [self.seatInfoList mutableCopy];
    NSArray *latestInfoList = [self latestMicInfoListFromEntry:entry];
    for (int i = 0; i < oldMutableList.count; i++) {
        RCVoiceSeatInfo *new = latestInfoList[i];
        RCVoiceSeatInfo *old = oldMutableList[i];
        if (old.status != new.status) {
            switch (new.status) {
                case RCSeatStatusEmpty:
                    if (old.status == RCSeatStatusLocking) {
                        if ([self.delegate respondsToSelector:@selector(seatDidLock:isLock:)]) {
                            [self.delegate seatDidLock:i isLock:NO];
                        }
                    }
                    if (old.status == RCSeatStatusUsing && old.userId != nil) {
                        if ([old.userId isEqualToString:self.currentUserId]) {
                            if ([self.delegate respondsToSelector:@selector(kickSeatDidReceive:)]) {
                                [self.delegate kickSeatDidReceive:i];
                            }
                            [self switchRole:RCRTCLiveRoleTypeAudience success:^{
                                
                            } error:^(NSInteger code, NSString * _Nonnull msg) {
                                
                            }];
                        } else {
                            if ([self.delegate respondsToSelector:@selector(userDidLeaveSeat:user:)]) {
                                [self.delegate userDidLeaveSeat:i user:old.userId];
                            }
                        }
                    }
                    break;
                case RCSeatStatusUsing:
                    if ([self.delegate respondsToSelector:@selector(userDidEnterSeat:user:)]) {
                        [self.delegate userDidEnterSeat:i user:new.userId];
                    }
                    break;
                case RCSeatStatusLocking:
                    if ([old.userId isEqualToString:self.currentUserId]) {
                        if ([self.delegate respondsToSelector:@selector(kickSeatDidReceive:)]) {
                            [self.delegate kickSeatDidReceive:i];
                        }
                        [self switchRole:RCRTCLiveRoleTypeAudience success:^{
                            
                        } error:^(NSInteger code, NSString * _Nonnull msg) {
                            
                        }];
                    }
                    if ([self.delegate respondsToSelector:@selector(seatDidLock:isLock:)]) {
                        [self.delegate seatDidLock:i isLock:YES];
                    }
                    break;
                default:
                    break;
            }
        }
        if (old.isMuted != new.isMuted) {
            if ([new.userId isEqualToString:self.currentUserId]) {
                [self disableAudioRecording:new.isMuted];
            }
            if ([self.delegate respondsToSelector:@selector(seatDidMute:isMute:)]) {
                [self.delegate seatDidMute:i isMute:new.isMuted];
            }
        }
    }
    self.seatInfoList = [latestInfoList subarrayWithRange:NSMakeRange(0, self.roomInfo.seatCount)];
    if ([self.delegate respondsToSelector:@selector(seatInfoDidUpdate:)]) {
        [self.delegate seatInfoDidUpdate:self.seatInfoList];
    }
}

- (void)handleRequestSeatKvUpdated:(NSDictionary<NSString *,NSString *> *)entry {
    BOOL hasUserWaitingSeat = NO;
    for (NSString *key in entry.allKeys) {
        if ([key containsString:RCRequestSeatPrefixKey]) {
            NSString *content = entry[key];
            if ([content isEqualToString:RCRequestSeatContentRequest]) {
                hasUserWaitingSeat = YES;
            }
            NSArray *list = [key componentsSeparatedByString:@"_"];
            if (list.count == 2) {
                NSString *userId = list[1];
                if ([userId isEqualToString:self.currentUserId]) {
                    if ([content isEqualToString:RCRequestSeatContentAccept]) {
                        if ([self.delegate respondsToSelector:@selector(requestSeatDidAccept)]) {
                            [self.delegate requestSeatDidAccept];
                        }
                        [self forceRemoveKV:key];
                    }
                    if ([content isEqual:RCRequestSeatContentDeny]) {
                        if ([self.delegate respondsToSelector:@selector(requestSeatDidReject)]) {
                            [self.delegate requestSeatDidReject];
                        }
                        [self forceRemoveKV:key];
                    }
                }
            }
        }
    }
    if (hasUserWaitingSeat) {
        if ([self.delegate respondsToSelector:@selector(requestSeatListDidChange)]) {
            [self.delegate requestSeatListDidChange];
        }
    }
}

- (void)handlePKUpdated:(NSDictionary<NSString *,NSString *> *)entry {
    if ([entry.allKeys containsObject:RCVoiceRoomPKInfoKey]) {
        NSString *json = entry[RCVoiceRoomPKInfoKey];
        RCVoicePKInfo *info = [RCVoicePKInfo modelWithJSON:json];
        if (info != nil) {
            self.currentPKInfo = info;
            if ([self.delegate respondsToSelector:@selector(pkOngoingWithInviterRoom:withInviterUserId:withInviteeRoom:withInviteeUserId:)]) {
                [self.delegate pkOngoingWithInviterRoom:info.inviterRoomId withInviterUserId:info.inviterUserId withInviteeRoom:info.inviteeRoomId withInviteeUserId:info.inviteeUserId];
            }
        }
    }
}

- (void)handleRequestSeatCancelled:(NSDictionary<NSString *,NSString *> *)entry {
    for (NSString *key in entry.allKeys) {
        if ([key hasPrefix:RCRequestSeatPrefixKey]) {
            if ([self.delegate respondsToSelector:@selector(requestSeatListDidChange)]) {
                [self.delegate requestSeatListDidChange];
            }
        }
    }
}

- (void)handlePKRemoved:(NSDictionary<NSString *,NSString *> *)entry {
    if ([entry.allKeys containsObject:RCVoiceRoomPKInfoKey]) {
        if ([self.delegate respondsToSelector:@selector(pkDidFinish)]) {
            [self.delegate pkDidFinish];
        }
    }
}

- (void)changeUserRoleIfNeeded {
    NSInteger userSeatIndex = [self seatIndexWhichUserSit:self.currentUserId];
    if (userSeatIndex >= 0 && self.currentRole != RCRTCLiveRoleTypeBroadcaster) {
        [self switchRole:RCRTCLiveRoleTypeBroadcaster success:^{
            
        } error:^(NSInteger code, NSString * _Nonnull msg) {
            
        }];
    }
    if ([self.delegate respondsToSelector:@selector(roomKVDidReady)]) {
        [self.delegate roomKVDidReady];
    }
}

- (void)updateKvRoomInfo:(RCVoiceRoomInfo *)roomInfo
                 success:(RCVoiceRoomSuccessBlock)successBlock
                   error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:self.roomId key:RCRoomInfoKey value:[roomInfo jsonString] sendNotification:NO autoDelete:NO notificationExtra:@"" success:^{
        [weakSelf runMainQueue:^{
            successBlock();
        }];
    } error:^(RCErrorCode nErrorCode) {
        [weakSelf runMainQueue:^{
            errorBlock(RCVoiceRoomSyncRoomInfoFailed, @"setup Room Info failed");
        }];
    }];
}


- (void)updateKvSeatInfo:(RCVoiceSeatInfo *)info
               seatIndex:(NSUInteger)seatIndex
                 success:(RCVoiceRoomSuccessBlock)successBlock error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:self.roomId key:[self seatInfoSeatPartKvKey:seatIndex] value:[info jsonString] sendNotification:NO autoDelete:NO notificationExtra:@"" success:^{
        [weakSelf runMainQueue:^{
            successBlock();
        }];
    } error:^(RCErrorCode nErrorCode) {
        [weakSelf runMainQueue:^{
            errorBlock(RCVoiceRoomSyncSeatInfoFailed, @"sync seat info failed");
        }];
    }];
}

- (void)updateRequestSeatKvWithUserID:(NSString *)userId
                              content: (NSString *)content
                              success:(RCVoiceRoomSuccessBlock)successBlock
                                error:(RCVoiceRoomErrorBlock)errorBlock {
    [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:self.roomId
                                                               key:[self RequestSeatKvKey:userId]
                                                             value:content
                                                  sendNotification:NO
                                                        autoDelete:YES
                                                 notificationExtra:@""
                                                           success:^{
        successBlock();
    } error:^(RCErrorCode nErrorCode) {
        errorBlock(RCVoiceRoomSyncRequestSeatFailed, @"update waiting kv failed");
    }];
}

- (void)switchRole:(RCRTCLiveRoleType)role
           success:(RCVoiceRoomSuccessBlock)successBlock
             error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    if (self.currentRole != role) {
        self.currentRole = role;
        [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
            if (isSuccess) {
                [weakSelf joinRTCRoom:self.roomId role:role success:successBlock error:errorBlock];
            } else {
                errorBlock(RCVoiceRoomJoinRoomFailed, @"switch role failed");
            }
        }];
        
    }
}

- (void)joinRTCRoom:(NSString *)roomId
               role:(RCRTCLiveRoleType)role
            success:(RCVoiceRoomSuccessBlock)successBlock
              error:(RCVoiceRoomErrorBlock)errorBlock {
    __weak typeof(self) weakSelf = self;
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType= RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudio;
    config.roleType = role;
    [[RCRTCEngine sharedInstance] joinRoom:roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        if (code == RCRTCCodeSuccess) {
            weakSelf.rtcRoom = room;
            weakSelf.rtcRoom.delegate = self;
            if (role == RCRTCLiveRoleTypeBroadcaster) {
                [weakSelf.rtcRoom.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode code) {
                    
                }];
                NSMutableArray *streams = [NSMutableArray array];
                for (RCRTCRemoteUser *remoteUser in room.remoteUsers) {
                    [streams addObjectsFromArray:remoteUser.remoteStreams];
                }
                if (streams.count > 0) {
                    [weakSelf.rtcRoom.localUser subscribeStream:streams tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {
                        
                    }];
                }
            } else {
                [weakSelf.rtcRoom.localUser subscribeStream:[weakSelf.rtcRoom getLiveStreams] tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {
                    
                }];
            }
            [weakSelf muteSelfIfNeeded];
            [weakSelf enableSpeaker:YES];
            [weakSelf setAudioQuality:RCVoiceRoomAudioQualityMusic scenario:RCVoiceRoomAudioScenarioMusicChatRoom];
            successBlock();
        } else {
            errorBlock(RCVoiceRoomJoinRoomFailed, @"join RTC room failed");
        }
    }];
}

- (void)runMainQueue:(void(^)(void))action {
    dispatch_async(dispatch_get_main_queue(), ^{
        action();
    });
}

- (BOOL)isUserOnSeat:(NSString *)userId {
    for (RCVoiceSeatInfo *seatInfo in self.seatInfoList) {
        if ([userId isEqualToString: seatInfo.userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)seatIndexWhichUserSit:(NSString *)userId {
    for (int i = 0; i < self.seatInfoList.count; i++) {
        RCVoiceSeatInfo *info = self.seatInfoList[i];
        if (info.userId == nil) {
            continue;;
        }
        if ([info.userId isEqualToString:userId]) {
            return i;
        }
    }
    return -1;
}

- (BOOL)seatIndexInRange:(NSInteger)index {
    if (index >= 0 && index < self.seatInfoList.count) {
        return YES;
    }
    return NO;
}

- (void)initialSeatInfoListIfNeeded {
    NSMutableArray *array = [NSMutableArray array];
    if (!self.seatInfoList || self.seatInfoList.count == 0) {
        for (int i = 0; i < self.roomInfo.seatCount; i++) {
            RCVoiceSeatInfo *seatInfo = [[RCVoiceSeatInfo alloc] init];
            [array addObject:seatInfo];
        }
        self.seatInfoList = [array copy];
    }
}

- (NSArray *)resetListExceptOwnerSeat:(NSInteger)count {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:self.seatInfoList.firstObject];
    for (int i = 1; i < count; i++) {
        RCVoiceSeatInfo *seatInfo = [[RCVoiceSeatInfo alloc] init];
        [array addObject:seatInfo];
        [self updateKvSeatInfo:seatInfo seatIndex:i success:^{
            
        } error:^(RCVoiceRoomErrorCode code, NSString * _Nonnull msg) {
            
        }];
    }
    return array.copy;
}

- (NSArray *)latestMicInfoListFromEntry:(NSDictionary<NSString *,NSString *> *)entry {
    NSMutableArray *array = [NSMutableArray array];
    if (self.seatInfoList.count != self.roomInfo.seatCount) {
        NSInteger maxCount = MAX(self.seatInfoList.count, self.roomInfo.seatCount);
        return [self resetListExceptOwnerSeat:maxCount];
    } else {
        for (int i = 0; i < self.roomInfo.seatCount; i++) {
            NSString *seatKey = [self seatInfoSeatPartKvKey:i];
            RCVoiceSeatInfo *new;
            if ([entry.allKeys containsObject:seatKey]) {
                new = [RCVoiceSeatInfo modelWithJSON:entry[seatKey]];
            }
            if (!new) {
                new = self.seatInfoList[i];
            }
            [array addObject:new];
        }
        return [array copy];
    }
}

- (NSString *)generateInvitationIdWithTargetId:(NSString *)targetId cmd:(NSUInteger)cmd senderId:(NSString *)senderId content:(NSString *)content {
    NSArray *array = @[senderId, targetId, [NSString stringWithFormat:@"%lud", (unsigned long)cmd]];
    if(content != nil && content.length > 0) {
        array = [array arrayByAddingObject:content];
    }
    return [array componentsJoinedByString:@","];
}

- (void)replaceSeatWithIndex:(NSUInteger)index seatInfo:(RCVoiceSeatInfo *)info {
    NSMutableArray *list = [self.seatInfoList mutableCopy];
    list[index] = info;
    self.seatInfoList = [list copy];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)handleTerminateNotification: (NSNotification *)noification {
    [self leaveRoom:^{
        
    } error:^(NSInteger code, NSString * _Nonnull msg) {
        
    }];
}

- (void)muteSelfIfNeeded {
    NSInteger userCurrentSeatIndex = [self seatIndexWhichUserSit:self.currentUserId];
    if (userCurrentSeatIndex >= 0) {
        RCVoiceSeatInfo *seatInfo = self.seatInfoList[userCurrentSeatIndex];
        [self disableAudioRecording:seatInfo.isMuted];
    }
}

- (void)forceRemoveKV:(NSString *)key {
    [[RCChatRoomClient sharedChatRoomClient] forceRemoveChatRoomEntry:self.roomId key:key sendNotification:NO notificationExtra:@"" success:^{
        
    } error:^(RCErrorCode nErrorCode) {
        
    }];
}

- (void)clearAll {
    self.roomId = nil;
    self.roomInfo = nil;
    self.seatInfoList = [NSArray array];
    self.rtcRoom = nil;
    _delegate = nil;
}

+ (NSString *)getVersion {
    return RCVoiceRoomSDkVersion;
}
@end
