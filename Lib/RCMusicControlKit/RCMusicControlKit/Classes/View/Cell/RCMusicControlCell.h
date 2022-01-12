//
//  RCMusicControlCell.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RCMusicControlCellStyle) {
    RCMusicControlCellStyleSlider = 1,
    RCMusicControlCellStyleSwitch,
};

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicControlCell : UITableViewCell
@property (class, nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign) RCMusicControlCellStyle cellStyle;
@property (nonatomic, copy) NSDictionary *cellData;
@property (nonatomic, copy) void(^controlAction)(RCMusicControlCellStyle cellStyle, NSString *text ,NSInteger value);

@end

NS_ASSUME_NONNULL_END
