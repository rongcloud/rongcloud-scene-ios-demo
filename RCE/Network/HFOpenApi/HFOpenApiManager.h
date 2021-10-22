//
//  HFOpenApiManager.h
//  HFOpenApi
//
//  Created by 郭亮 on 2021/3/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HFAPISDK_CODE) {
    HFVSDK_CODE_NoRegister = 20500, // 未注册
    HFVSDK_CODE_NoLogin, // 未登录
    HFVSDK_CODE_NoParameter, // 参数不全
    HFVSDK_CODE_ParameterError,//参数字符格式签名错误
    HFVSDK_CODE_JsonError, // json解析错误
    HFVSDK_CODE_NoNetwork, //无网络连接
    HFVSDK_CODE_RequestTimeOut, //请求超时
};

@protocol HFOpenApiErrorProtocol <NSObject>

@optional

- (void)onSendRequestErrorCode:(HFAPISDK_CODE)errorCode info:(NSDictionary *)info;
- (void)onServerErrorCode:(int)errorCode info:(NSDictionary *)info;

@end

@interface HFOpenApiManager : NSObject

@property(nonatomic ,weak)id <HFOpenApiErrorProtocol> delegate;

+(HFOpenApiManager *)shared;

/// 初始化SDK
/// @param appId appId
/// @param serverCode serverCode
/// @param clientId 用户唯一标识（公司自有的用户ID）
/// @param version 操作的 API 的版本
/// @param success 成功回调
/// @param fail 失败回调
- (void)registerAppWithAppId:(NSString *_Nonnull)appId
                  serverCode:(NSString *_Nonnull)serverCode
                    clientId:(NSString *_Nonnull)clientId
                     version:(NSString *_Nonnull)version
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 电台获取音乐列表
/// 电台列表
/// @param success 成功回调
/// @param fail 失败回调
-(void)channelWithSuccess:(void (^_Nullable)(id  _Nullable response))success
                     fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 电台获取歌单列表
/// @param groupId 电台id
/// @param language 语言版本 0-中文,1-英文
/// @param recoNum 推荐音乐数 0～10
/// @param page 当前页码，默认为1  大于0的整数
/// @param pageSize 每页显示条数，默认为10   1～100
/// @param success 成功回调
/// @param fail 失败回调
-(void)channelSheetWithGroupId:(NSString *_Nullable)groupId
                      language:(NSString *_Nullable)language
                       recoNum:(NSString *_Nullable)recoNum
                          page:(NSString *_Nullable)page
                      pageSize:(NSString *_Nullable)pageSize
                       success:(void (^_Nullable)(id  _Nullable response))success
                          fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 歌单获取音乐列表
/// @param sheetId 歌单id
/// @param language 语言版本，英文版本数据可能空，  0-中文,1-英文
/// @param page 当前页码，默认为1， 大于0的整数
/// @param pageSize 每页显示条数，默认为10，1～100
/// @param success 成功回调
/// @param fail 失败回调
-(void)sheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                    language:(NSString *_Nullable)language
                        page:(NSString *_Nullable)page
                    pageSize:(NSString *_Nullable)pageSize
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;


#pragma mark - 搜索获取音乐列表
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
-(void)searchMusicWithTagIds:(NSString *_Nullable)tagIds
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

/// 音乐配置信息
/// @param success 成功回调
/// @param fail 失败回调
-(void)musicConfigWithSuccess:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 音乐推荐
/// 登录获取token
/// @params nickname 昵称
/// @params gender 性别，默认0, 0:未知,1:男,2:女
/// @params birthday 出生日期，10位秒级时间戳
/// @params location 经纬度信息，纬度在前
/// @params education 所受教育水平
/// @params profession 职业
/// @params isOrganization 是否属于组织机构类型用户（to B），默认false
/// @params reserve json字符串，保留字段用于扩展用户其他信息
/// @params favoriteSinger 喜欢的歌手名，多个用英文逗号拼接
/// @params favoriteGenre 喜欢的音乐流派Id，多个用英文逗号拼接
-(void)baseLoginWithNickname:(NSString *_Nullable)nickname
                      gender:(NSString *_Nullable)gender
                    birthday:(NSString *_Nullable)birthday
                    location:(NSString *_Nullable)location
                   education:(NSString *_Nullable)education
                  profession:(NSString *_Nullable)profession
              isOrganization:(BOOL)isOrganization
                     reserve:(NSString *_Nullable)reserve
              favoriteSinger:(NSString *_Nullable)favoriteSinger
               favoriteGenre:(NSString *_Nullable)favoriteGenre
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;


/// 行为采集
/// @param action 枚举定义用户行为
/// @param targetId 行为操作的对象（音乐或分类id）
/// @param content 根据action传入格式
/// @param location 经纬度信息，纬度在前
/// @param success 成功回调
/// @param fail 失败回调
-(void)baseReportWithAction:(NSString *_Nonnull)action
                   targetId:(NSString *_Nonnull)targetId
                    content:(NSString *_Nullable)content
                   location:(NSString *_Nullable)location
                    success:(void (^_Nullable)(id  _Nullable response))success
                       fail:(void (^_Nullable)(NSError * _Nullable error))fail;


/// 猜你喜欢，此接口根据用户画像、行为及行业等综合信息像接入平台的用户推荐音乐内容
/// @param page 当前页码，默认为1,大于0的整数
/// @param pageSize 每页显示条数，默认为10, 1~100
/// @param success 成功回调
/// @param fail 失败回调
-(void)baseFavoriteWithPage:(NSString *_Nullable)page
                   pageSize:(NSString *_Nullable)pageSize
                    success:(void (^_Nullable)(id  _Nullable response))success
                       fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 热门推荐
/// @param startTime 10位秒级时间戳
/// @param duration 距离StartTime过去的天数，1～365
/// @param page 当前页码，默认为1,大于0的整数
/// @param pageSize 每页显示条数，默认为10, 1~100
/// @param success 成功回调
/// @param fail 失败回调
-(void)baseHotWithStartTime:(NSString * _Nonnull)startTime
                   duration:(NSString * _Nonnull)duration
                       page:(NSString *_Nullable)page
                   pageSize:(NSString *_Nullable)pageSize
                    success:(void (^_Nullable)(id  _Nullable response))success
                       fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 音乐播放
/// 歌曲试听
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
-(void)trafficTrialWithMusicId:(NSString *_Nonnull)musicId
                       success:(void (^_Nullable)(id  _Nullable response))success
                          fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 获取音乐HQ播放信息
/// @param musicId 音乐id
/// @param audioFormat 文件编码,默认mp3,  mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320, 320 / 128
/// @param success 成功回调
/// @param fail 失败回调
-(void)trafficHQListenWithMusicId:(NSString *_Nonnull)musicId
                      audioFormat:(NSString *_Nullable)audioFormat
                        audioRate:(NSString *_Nullable)audioRate
                          success:(void (^_Nullable)(id  _Nullable response))success
                             fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 音/视频作品BGM音乐播放
/// 歌曲试听
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
-(void)ugcTrialWithMusicId:(NSString *_Nonnull)musicId
                   success:(void (^_Nullable)(id  _Nullable response))success
                      fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 获取音乐HQ播放信息
/// @param musicId 音乐id
/// @param audioFormat 文件编码,默认mp3,  mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320, 320 / 128
/// @param success 成功回调
/// @param fail 失败回调
-(void)ugcHQListenWithMusicId:(NSString *_Nonnull)musicId
                audioFormat:(NSString *_Nullable)audioFormat
                  audioRate:(NSString *_Nullable)audioRate
                    success:(void (^_Nullable)(id  _Nullable response))success
                       fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 在线K歌音乐播放
/// 歌曲试听
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
-(void)kTrialWithMusicId:(NSString *_Nonnull)musicId
                 success:(void (^_Nullable)(id  _Nullable response))success
                    fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 获取音乐HQ播放信息
/// @param musicId 音乐id
/// @param audioFormat 文件编码,默认mp3,  mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320, 320 / 128
/// @param success 成功回调
/// @param fail 失败回调
-(void)kHQListenWithMusicId:(NSString *_Nonnull)musicId
              audioFormat:(NSString *_Nullable)audioFormat
                audioRate:(NSString *_Nullable)audioRate
                  success:(void (^_Nullable)(id  _Nullable response))success
                     fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 音乐售卖
/// 歌曲试听
/// @param musicId 音乐id
/// @param success 成功回调
/// @param fail 失败回调
-(void)orderTrialWithMusicId:(NSString *_Nonnull)musicId
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 购买音乐
/// @param subject 商品描述
/// @param orderId 公司自己生成的订单id
/// @param deadline 作品授权时长，以天为单位，0代表永久授权
/// @param music 购买详情，encode转化后的json字符串 （musicId->音乐id；price->音乐单价，单位分；num->购买数量）
/// @param language 语言版本 0-中文,1-英文
/// @param audioFormat 文件编码,默认mp3, mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320,  320 / 128
/// @param totalFee 售出总价，单位：分
/// @param remark 备注
/// @param workId 公司自己生成的作品id,多个以“,”拼接
/// @param success 成功回调
/// @param fail 失败回调
-(void)orderMusicWithSubject:(NSString *_Nonnull)subject
                     orderId:(NSString *_Nonnull)orderId
                    deadline:(NSString *_Nonnull)deadline
                       music:(NSString *_Nonnull)music
                    language:(NSString *_Nullable)language
                 audioFormat:(NSString *_Nullable)audioFormat
                   audioRate:(NSString *_Nullable)audioRate
                    totalFee:(NSString *_Nonnull)totalFee
                      remark:(NSString *_Nullable)remark
                      workId:(NSString *_Nullable)workId
                     success:(void (^_Nullable)(id  _Nullable response))success
                        fail:(void (^_Nullable)(NSError * _Nullable error))fail;


/// 查询订单
/// @param orderId 公司自己生成的订单id
/// @param success 成功回调
/// @param fail 失败回调
-(void)orderDetailWithOrderId:(NSString *_Nonnull)orderId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 下载授权书
/// @param companyName 公司名称
/// @param projectName 项目名称
/// @param brand 项目品牌
/// @param period 授权期限（0:半年、1:1年、2:2年、3:3年、4:随片永久）
/// @param area 授权地区（0:中国大陆、1:大中华、2:全球）
/// @param orderIds 授权订单ID列表，多个ID用","隔开
/// @param success 成功回调
/// @param fail 失败回调
-(void)orderAuthorizationWithCompanyName:(NSString *_Nonnull)companyName
                             projectName:(NSString *_Nonnull)projectName
                                   brand:(NSString *_Nonnull)brand
                                  period:(NSString *_Nonnull)period
                                    area:(NSString *_Nonnull)area
                                orderIds:(NSString *_Nonnull)orderIds
                                 success:(void (^_Nullable)(id  _Nullable response))success
                                    fail:(void (^_Nullable)(NSError * _Nullable error))fail;


#pragma mark - 数据上报
/// 音乐数据上报
/// @param musicId 音乐id
/// @param duration 播放时长
/// @param timestamp 13位毫秒级时间戳
/// @param audioFormat 音频格式 文件编码，(mp3 / aac)
/// @param audioRate 音频码率 音质，音乐播放时的比特率，(320 / 128)
/// @param success 成功回调
/// @param fail 失败回调
-(void)trafficReportListenWithMusicId:(NSString *_Nonnull)musicId
                             duration:(NSString *_Nonnull)duration
                            timestamp:(NSString *_Nonnull)timestamp
                          audioFormat:(NSString *_Nonnull)audioFormat
                            audioRate:(NSString *_Nonnull)audioRate
                              success:(void (^_Nullable)(id  _Nullable response))success
                                 fail:(void (^_Nullable)(NSError * _Nullable error))fail;


/// 音/视频音乐数据上报
/// @param musicId 音乐id
/// @param duration 播放时长
/// @param timestamp 13位毫秒级时间戳
/// @param audioFormat 音频格式 文件编码，(mp3 / aac)
/// @param audioRate 音频码率 音质，音乐播放时的比特率，(320 / 128)
/// @param success 成功回调
/// @param fail 失败回调
-(void)ugcReportListenWithMusicId:(NSString *_Nonnull)musicId
                         duration:(NSString *_Nonnull)duration
                        timestamp:(NSString *_Nonnull)timestamp
                      audioFormat:(NSString *_Nonnull)audioFormat
                        audioRate:(NSString *_Nonnull)audioRate
                          success:(void (^_Nullable)(id  _Nullable response))success
                             fail:(void (^_Nullable)(NSError * _Nullable error))fail;


/// 在线K歌音乐数据上报
/// @param musicId 音乐id
/// @param duration 播放时长
/// @param timestamp 13位毫秒级时间戳
/// @param audioFormat 音频格式 文件编码，(mp3 / aac)
/// @param audioRate 音频码率 音质，音乐播放时的比特率，(320 / 128)
/// @param success 成功回调
/// @param fail 失败回调
-(void)kReportListenWithMusicId:(NSString *_Nonnull)musicId
                       duration:(NSString *_Nonnull)duration
                      timestamp:(NSString *_Nonnull)timestamp
                    audioFormat:(NSString *_Nonnull)audioFormat
                      audioRate:(NSString *_Nonnull)audioRate
                        success:(void (^_Nullable)(id  _Nullable response))success
                           fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 发布作品
/// @param orderId 公司自己生成的订单id
/// @param workId 公司自己生成的作品id,多个以“,”拼接
/// @param success 成功回调
/// @param fail 失败回调
-(void)orderPublishWithOrderId:(NSString *_Nonnull)orderId
                       workId:(NSString *_Nonnull)workId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

#pragma mark - 会员歌单
/// 创建会员歌单
/// @param sheetName 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)createMemberWithSheetName:(NSString *_Nonnull)sheetName
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 删除会员歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)deleteMemberWithSheetId:(NSString *_Nonnull)sheetId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 会员歌单列表
/// @param memberOutId 会员歌单名称
/// @param page 当前页
/// @param pageSize 每页显示条数，默认 10
/// @param success 成功回调
/// @param fail 失败回调
-(void)fetchMemberSheetListWithMemberOutId:(NSString *_Nonnull)memberOutId
                                      page:(NSString *_Nullable)page
                                  pageSize:(NSString *_Nullable)pageSize
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 获取会员歌单歌曲
/// @param sheetId 会员歌单名称
/// @param page 当前页
/// @param pageSize 每页显示条数，默认 10
/// @param success 成功回调
/// @param fail 失败回调
-(void)fetchMemberSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                                      page:(NSString *_Nullable)page
                                  pageSize:(NSString *_Nullable)pageSize
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 音乐加入歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)addSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                       musicId:(NSString *_Nonnull)musicId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 音乐移除歌单
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)removeSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                       musicId:(NSString *_Nonnull)musicId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;

/// 清空会员歌单音乐列表
/// @param sheetId 会员歌单名称
/// @param success 成功回调
/// @param fail 失败回调
-(void)clearSheetMusicWithSheetId:(NSString *_Nonnull)sheetId
                      success:(void (^_Nullable)(id  _Nullable response))success
                         fail:(void (^_Nullable)(NSError * _Nullable error))fail;
@end


