//
//  HFOpenAction.h
//  HFOpenApi
//
//  Created by 郭亮 on 2021/3/16.
//

#import <Foundation/Foundation.h>

@interface HFOpenAction : NSObject

//---电台获取音乐列表---
//电台列表
extern NSString *const Action_Channel;
//电台获取歌单列表
extern NSString *const ACtion_ChannelSheet;
//歌单获取音乐列表
extern NSString *const Action_SheetMusic;

//---搜索获取音乐列表---
//组合搜索音乐列表
extern NSString *const Action_SearchMusic;
//组合搜索音乐配置信息
extern NSString *const Action_MusicConfig;

//---音乐推荐---
//猜你喜欢
extern NSString *const Action_BaseFavorite;
//热门推荐
extern NSString *const Action_BaseHot;

//---音乐播放---
//歌曲试听
extern NSString *const Action_Trial;
//补充
extern NSString *const Action_TrafficTrial;
extern NSString *const Action_UGCTrial;
extern NSString *const Action_KTrial;
extern NSString *const Action_OrderTrial;



//获取音乐HQ播放信息
extern NSString *const Action_TrafficHQListen;
//补充
extern NSString *const Action_UGCHQListen;
extern NSString *const Action_KHQListen;



//获取音乐混音播放信息
extern NSString *const Action_TrafficListenMixed;

//---音乐售卖---
//购买音乐
extern NSString *const Action_OrderMusic;
//查询订单
extern NSString *const Action_OrderDetail;
//下载授权书
extern NSString *const Action_OrderAuthorization;

//---数据上报---
//获取token
extern NSString *const Action_BaseLogin;
//行为采集
extern NSString *const Action_BaseReport;
//发布作品
extern NSString *const Action_OrderPublish;


extern NSString *const Action_TrafficReportListen;
extern NSString *const Action_UGCReportListen;
extern NSString *const Action_KReportListen;

//4.1.2

/// 创建会员歌单
extern NSString *const Action_CreateMemberSheet ;
/// 删除会员歌单
extern NSString *const Action_DeleteMemberSheet ;
///获取会员歌单
extern NSString *const Action_MemberSheet ;
///获取会员歌单歌曲
extern NSString *const Action_MemberSheetMusic ;
/// 增加会员歌单歌曲
extern NSString *const Action_AddMemberSheetMusic ;
/// 移除会员歌单歌曲
extern NSString *const Action_RemoveMemberSheetMusic ;
/// 清除会员歌单歌曲
extern NSString *const Action_ClearMemberSheetMusic ;
@end


