//
//  RCAttribute.h
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/9.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCCorner : NSObject
/// radius 优先级最低，其他有值以其他为准
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat leftTop;
@property (nonatomic, assign) CGFloat rightTop;
@property (nonatomic, assign) CGFloat rightBottom;
@property (nonatomic, assign) CGFloat leftBottom;
@end


@interface RCInsets : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@end


@interface RCColor : NSObject
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;
@end


@interface RCImage : NSObject
@property (nonatomic, copy, nullable) NSString *local;
@property (nonatomic, copy, nullable) NSString *remote;
@end


@interface RCFont : NSObject
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGFloat weight;
@end


@interface RCSize : NSObject
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end


@interface RCColorSelector : NSObject
@property (nonatomic, strong, nullable) RCColor *normal;
@property (nonatomic, strong, nullable) RCColor *select;
@end

@interface RCImageSelector : NSObject
@property (nonatomic, strong, nullable) RCImage *normal;
@property (nonatomic, strong, nullable) RCImage *select;
@end


@interface RCFontSelector : NSObject
@property (nonatomic, strong, nullable) RCFont *normal;
@property (nonatomic, strong, nullable) RCFont *select;
@end


@interface RCAttribute : NSObject
@property (nonatomic, strong, nullable) RCColor  *textColor;
@property (nonatomic, strong, nullable) RCFont   *font;
@property (nonatomic, copy, nullable)   NSString *text;
@property (nonatomic, strong, nullable) RCColor  *hintColor;
@property (nonatomic, strong, nullable) NSString *hintText;
@property (nonatomic, strong, nullable) RCColor  *background;
@property (nonatomic, strong, nullable) RCCorner *corner;
@property (nonatomic, strong, nullable) RCImageSelector *imageSelector;
@property (nonatomic, strong, nullable) RCColorSelector *colorSelector;
@property (nonatomic, strong, nullable) RCFontSelector  *fontSelector;
@property (nonatomic, strong, nullable) RCSize   *size;
@property (nonatomic, strong, nullable) RCInsets *insets;
@property (nonatomic, strong, nullable) RCImage  *image;
@end

NS_ASSUME_NONNULL_END
