//
//  HFOpenAction.m
//  HFOpenApi
//
//  Created by 郭亮 on 2021/3/16.
//

#import "HFOpenAction.h"

@implementation HFOpenAction

NSString *const Action_Channel = @"Channel";
NSString *const ACtion_ChannelSheet = @"ChannelSheet";
NSString *const Action_SheetMusic = @"SheetMusic";
NSString *const Action_SearchMusic = @"SearchMusic";
NSString *const Action_MusicConfig = @"MusicConfig";
NSString *const Action_BaseFavorite = @"BaseFavorite";
NSString *const Action_BaseHot = @"BaseHot";
NSString *const Action_Trial = @"Trial";
NSString *const Action_TrafficHQListen = @"TrafficHQListen";
NSString *const Action_TrafficListenMixed = @"TrafficListenMixed";
NSString *const Action_OrderMusic = @"OrderMusic";
NSString *const Action_OrderDetail = @"OrderDetail";
NSString *const Action_OrderAuthorization = @"OrderAuthorization";
NSString *const Action_BaseLogin = @"BaseLogin";
NSString *const Action_BaseReport = @"BaseReport";
NSString *const Action_OrderPublish = @"OrderPublish";
NSString *const Action_TrafficTrial = @"TrafficTrial";
NSString *const Action_UGCTrial = @"UGCTrial";
NSString *const Action_KTrial = @"KTrial";
NSString *const Action_OrderTrial = @"OrderTrial";
NSString *const Action_UGCHQListen = @"UGCHQListen";
NSString *const Action_KHQListen = @"KHQListen";
NSString *const Action_TrafficReportListen = @"TrafficReportListen";
NSString *const Action_UGCReportListen = @"UGCReportListen";
NSString *const Action_KReportListen = @"KReportListen";
//4.1.2

/// 创建会员歌单
NSString *const Action_CreateMemberSheet = @"CreateMemberSheet";
/// 删除会员歌单
NSString *const Action_DeleteMemberSheet = @"DeleteMemberSheet";
///获取会员歌单
NSString *const Action_MemberSheet = @"MemberSheet";
///获取会员歌单歌曲
NSString *const Action_MemberSheetMusic = @"MemberSheetMusic";
/// 增加会员歌单歌曲
NSString *const Action_AddMemberSheetMusic = @"AddMemberSheetMusic";
/// 移除会员歌单歌曲
NSString *const Action_RemoveMemberSheetMusic = @"RemoveMemberSheetMusic";
/// 清除会员歌单歌曲
NSString *const Action_ClearMemberSheetMusic = @"ClearMemberSheetMusic";








@end
