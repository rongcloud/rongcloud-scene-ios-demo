//
//  RCMusicWebService.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <Foundation/Foundation.h>

@class RCMusicChannelData;
@class RCMusicSheetResponse;
@class RCMusicResponse;
@class RCMusicData;
@class RCMusicDetail;
@class RCMusicSheetData; 
NS_ASSUME_NONNULL_BEGIN

@interface RCMusicWebService : NSObject
/// 电台列表
/// @param success 成功回调
/// @param failure 失败回调
+ (void)channelWithSuccess:(void (^)(NSArray<RCMusicChannelData *> * _Nullable response))success
                     fail:(void (^)(NSError *error))failure;

/// 电台获取歌单列表
/// @param groupId 电台id
/// @param language 语言版本 0-中文,1-英文
/// @param recoNum 推荐音乐数 0～10
/// @param page 当前页码，默认为1  大于0的整数
/// @param pageSize 每页显示条数，默认为10   1～100
/// @param success 成功回调
/// @param failure 失败回调
+ (void)channelSheetWithGroupId:(nullable NSString *)groupId
                      language:(nullable NSString *)language
                       recoNum:(nullable NSString *)recoNum
                          page:(nullable NSString *)page
                      pageSize:(nullable NSString *)pageSize
                       success:(void (^)(RCMusicSheetData * _Nullable response))success
                          fail:(void (^)(NSError *error))failure;

/// 歌单获取音乐列表
/// @param sheetId 歌单id
/// @param language 语言版本，英文版本数据可能空，  0-中文,1-英文
/// @param page 当前页码，默认为1， 大于0的整数
/// @param pageSize 每页显示条数，默认为10，1～100
/// @param success 成功回调
/// @param failure 失败回调
+ (void)sheetMusicWithSheetId:(nullable NSString *)sheetId
                    language:(nullable NSString *)language
                        page:(nullable NSString *)page
                    pageSize:(nullable NSString *)pageSize
                     success:(void (^)(RCMusicData * _Nullable response))success
                        fail:(void (^)(NSError *error))failure;

/// 获取音乐HQ播放信息
/// @param musicId 音乐id
/// @param audioFormat 文件编码,默认mp3,  mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320, 320 / 128
/// @param success 成功回调
/// @param failure 失败回调
+ (void)trafficHQListenWithMusicId:(nonnull NSString *)musicId
                      audioFormat:(nullable NSString *)audioFormat
                        audioRate:(nullable NSString *)audioRate
                          success:(void (^)(RCMusicDetail  * _Nullable response))success
                             fail:(void (^)(NSError * _Nullable error))failure;

/// 组合搜索
/// @param tagIds 标签Id，多个Id以“,”拼接
/// @param priceFromCent 价格区间的最低值，单位分
/// @param priceToCent 价格区间的最高值，单位分
/// @param bpmFrom BPM区间的最低值
/// @param bpmTo BPM区间的最高值
/// @param durationFrom 时长区间的最低值,单位秒
/// @param durationTo 时长区间的最高值,单位秒
/// @param keyword 搜索关键词，搜索条件歌名、专辑名、艺人名、标签名
/// @param language 语言版本，英文版本数据可能空, 0-中文,1-英文
/// @param searchFiled Keywords参数指定搜索条件，不传时默认搜索条件歌名、专辑名、艺人名、标签名
/// @param searchSmart 是否启用分词, 0｜1
/// @param page 当前页码，默认为1,大于0的整数
/// @param pageSize 每页显示条数，默认为10, 1~100
/// @param success 成功回调
/// @param fail 失败回调
+ (void)searchMusicWithTagIds:(NSString *_Nullable)tagIds
               priceFromCent:(NSString *_Nullable)priceFromCent
                 priceToCent:(NSString *_Nullable)priceToCent
                     bpmFrom:(NSString *_Nullable)bpmFrom
                       bpmTo:(NSString *_Nullable)bpmTo
                durationFrom:(NSString *_Nullable)durationFrom
                  durationTo:(NSString *_Nullable)durationTo
                     keyword:(NSString *_Nullable)keyword
                    language:(NSString *_Nullable)language
                 searchFiled:(NSString *_Nullable)searchFiled
                 searchSmart:(NSString *_Nullable)searchSmart
                        page:(NSString *_Nullable)page
                    pageSize:(NSString *_Nullable)pageSize
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;
@end

NS_ASSUME_NONNULL_END
