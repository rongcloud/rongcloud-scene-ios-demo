//
//  MHBeautyManager.h


#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>
#import "MHFiltersContants.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MHBeautyManagerDelegate <NSObject>
@optional
- (void)getManagerActionStatus:(BOOL)hidden;
- (void)getFaceStatus:(BOOL)status;
- (void)getFaceBoundRects:(NSMutableArray*)boundRects;
@end
@interface MHBeautyManager : NSObject

@property (nonatomic, weak) id<MHBeautyManagerDelegate> delegate;


/// 腾讯直播用
/// @param texture 纹理数据
/// @param width 纹理数据
/// @param height 纹理数据
- (GLuint)getTexrureProcessWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;

/**
 处理纹理数据
 
 @param texture 纹理数据
 @param width 纹理数据
 @param height 纹理数据
 */

- (void)processWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;
 
/**
    处理纹理数据
    @param texture 纹理数据
    @param width 宽度
    @param height 高度
    @param scale 缩放比例(0~1)
 */

- (GLuint)processWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height  scale:(float)scale;
/**
 处理iOS封装的数据
 
 @param pixelBuffer BGRA格式数据
 @param formatType 只支持kCVPixelFormatType_420YpCbCr8BiPlanarFullRange 和 kCVPixelFormatType_32BGRA
 */

- (void)processWithPixelBuffer:(CVPixelBufferRef)pixelBuffer formatType:(OSType)formatType;

//TTT视频通话
- (void)process3TWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

//融云SDK使用
- (void)processWithRoatePixelBuffer:(CVPixelBufferRef)pixelBuffer formatType:(OSType)formatType;

//即构实时音视频专用
- (void)processZGWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
// Agora视频通话
-(void)processAgoraWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
//七牛
-(void)processPLStreamWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
//阿里直播适用
- (void)processAliStreamWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;
///阿里音视频
- (GLuint)processAliRTCWithTexture:(GLuint)texture width:(GLint)width height:(GLint)height;

/**
 清空所有资源，为防止内存泄露，退出页面销毁时请调用此接口
 */
- (void)destroy;

/// 美白
/// @param skinWhiting 美白参数，参数0.0到1.0，0是正常值
- (void)setSkinWhiting:(CGFloat)skinWhiting;

/// 磨皮
/// @param buffing 磨皮参数，参数0.0到1.0，0是正常值
- (void)setBuffing:(CGFloat)buffing;

/// 红润
/// @param ruddiness 红润参数，参数0.0到1.0，0是正常值
- (void)setRuddiness:(CGFloat)ruddiness;

/// 锐化
/// @param sharpen 锐化参数0.0-1.0
- (void)setSharpen:(CGFloat)sharpen;

/**
 大眼

 @param bigEye 参数0.0到100.0，0是正常值
 */
- (void)setBigEye:(int)bigEye;

/**
 瘦脸

 @param faceLift 参数0.0到100.0，0是正常值
 */
- (void)setFaceLift:(int)faceLift;

/**
 瘦鼻

 @param noseLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setNoseLift:(int)noseLift;

/**
 嘴型

 @param mouthLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setMouthLift:(int)mouthLift;

/**
 下巴

 @param chinLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
-(void)setChinLift:(int)chinLift;

/**
 额头

 @param foreheadLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setForeheadLift:(int)foreheadLift;

/**
 长鼻

 @param lengthenNoseLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setLengthenNoseLift:(int)lengthenNoseLift;


/**
 眉毛

 @param eyeBrownLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setEyeBrownLift:(int)eyeBrownLift;

/**
 眼角

 @param eyeAngleLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setEyeAngleLift:(int)eyeAngleLift;

/**
 开眼角

 @param eyeAlaeLift 参数0.0到100.0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setEyeAlaeLift:(int)eyeAlaeLift;

/**
 眼距

 @param eyeDistanceLift 参数0.0到100.0，0是不设置，50为默认值。0-50为缩小，50-100为放大
 */
- (void)setEyeDistanceLift:(int)eyeDistanceLift;

/**
 削脸

 @param shaveFaceLift ，参数0.0到100.0，0是正常值。
 */
- (void)setShaveFaceLift:(int)shaveFaceLift;

/**
 贴纸

 @param stickerContent stickerContent
 */
- (void)setSticker:(NSString *)stickerContent withLevel:(NSInteger)level;

/// 动作识别
/// @param stickerContent <#stickerContent description#>
/// @param action 0,1,2,3分别代表不需要识别，抬头，张嘴，眨眼
- (void)setSticker:(NSString *)stickerContent action:(int)action;

/**
 特效

 @param jitter MHJitterType，详情参见MHFiltersContants.h
 */
- (void)setJitterType:(MHJitterType)jitter;

/**
 哈哈镜

 @param distort MHDistortType，详情参见MHFiltersContants.h
 */
- (void)setDistortType:(MHDistortType)distort withIsMenu:(BOOL)isMenu;

/**
 滤镜

 @param filterType MHFilterType，详情参见MHFiltersContants.h
 */

- (void)setFilterType:(NSInteger)filterType newFilterInfo:(NSDictionary *)info;

/// 不知道
/// @param filterType <#filterType description#>
- (void)setFilterType:(NSInteger)filterType;
//仅适用于浪漫、清新、唯美、粉嫩、怀旧、蓝调、清凉、日系
- (void)setFilterLift:(int)filterLift;
/**
 亮度

 @param brightnessLift 亮度 0 to 100.0,  50.0 as the normal level
 */
- (void)setBrightnessLift:(int)brightnessLift;

/**
 水印
 
 @param watermark 图片名称
 @param alignment 水印位置 详情参见MHFiltersContants.h
 */
- (void)setWatermark:(NSString *)watermark alignment:(MHWatermarkAlign)alignment;
//范围是CGRect:0-1

/// 设置水印位置和宽高，宽高的范围均为0-1，默认CGRectMake(0.04, 0.04, 0.1, 0)
/// @param cgRect CGRectMake(0.04, 0.04, 0.1, 0)
- (void)setWatermarkRect:(CGRect)cgRect;

/// 设置人脸关键点的平滑系数
/// @param faceSmooth 人脸关键点的平滑系数 系数越小越稳定，相应的识别跟踪速度会有影响。最小值0.01
-(void)setFaceKeyPointSmooth:(CGFloat)faceSmooth;
/**
 设置扫描人脸的最小像素,取值范围0～1
 */
- (void)setMinFaceSize:(CGFloat)minFaceSize;
/**
 美妆
 
 @param makeType 美妆类型 详情参见MHFiltersContants.h
 @param on 开关
 */

- (void)setBeautyManagerMakeUpType:(MHMakeupType)makeType withOn:(BOOL)on;


@property (nonatomic, assign) int maxFace;

@property (nonatomic, assign) BOOL isUseSticker;
@property (nonatomic, assign) BOOL isUseFaceBeauty;
@property (nonatomic, assign) BOOL isUseOneKey;
@property (nonatomic, assign) BOOL isUseHaha;
@property (nonatomic, assign) BOOL isUseMakeUp;
- (void)releaseSession;

@end

NS_ASSUME_NONNULL_END

