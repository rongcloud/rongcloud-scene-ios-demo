//
//  RCMusicAppearanceData.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import "RCMusicAppearanceData.h"
#import "NSObject+YYModel.h"

@implementation RCMusicAppearanceValue

// UI元素基类
- (nullable id)appearanceValue {
    //根据字符串返回对应类型的数据 UIColor  UIEdgeInset  UIFont
    return nil;
}

@end

@implementation RCMusicAppearanceData

//根据字典初始化配置，dict为空提供默认配置
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (dict == nil) {
        return [RCMusicAppearanceData defaultAppearance];
    }
    if (self = [super init]) {
        
    }
    return self;
}

// 读取本地默认配置
+ (instancetype)defaultAppearance {
    static RCMusicAppearanceData *appearance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearance = [RCMusicAppearanceData yy_modelWithDictionary:[self dictionary]];
    });
    return appearance;
}

//默认配置解析
+ (NSDictionary *)dictionary {
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"RCMusicSource.bundle"];
    
    NSString *path = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"config" ofType:@"json"];

    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end

@implementation RCMusicModule
@end

@implementation RCMusicBarItemData

@end

@implementation RCMusicCategorySelectorData
@end

@implementation RCMusicMusicControlData
@end

@implementation RCMusicMusicListData

@end

@implementation RCMusicMusicListContentLabelAttribute

@end

@implementation RCMusicSoundEffectData
@end

@implementation RCMusicToolBarData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"items" : [RCMusicBarItem class]};
}
@end

@implementation RCMusicBarItem
@end

@implementation RCMusicColor
- (id)appearanceValue {
    return [UIColor colorWithRed:self.red.floatValue/255.0f green:self.green.floatValue/255.0f blue:self.blue.floatValue/255.0f alpha:self.alpha.floatValue];
}
@end

@implementation RCMusicInset
- (id)appearanceValue {
    return NSStringFromUIEdgeInsets(UIEdgeInsetsMake(self.top.floatValue, self.left.floatValue, self.bottom.floatValue, self.right.floatValue));
}
@end

@implementation RCMusicSize
- (id)appearanceValue {
    return NSStringFromCGSize(CGSizeMake(self.width.floatValue, self.height.floatValue));
}
@end

@implementation RCMusicCategorySelectorLabelAttributes

@end

@implementation RCMusicFont
- (id)appearanceValue {
    UIFontWeight weight  = UIFontWeightRegular;
    if (self.weight.integerValue == 700) {
        weight = UIFontWeightBold;
    }
    return [UIFont systemFontOfSize:self.size.integerValue weight:weight];
}
@end

@implementation RCMusicIcon
- (NSString *)source {
    if (self.remote && self.remote.length > 0) {
        return self.remote;
    }
    return self.local;
}
@end

