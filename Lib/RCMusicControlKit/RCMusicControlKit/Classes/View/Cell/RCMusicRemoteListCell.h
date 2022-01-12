//
//  RCMusicRemoteListCell.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import <UIKit/UIKit.h>
#import "RCMusicInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMusicRemoteListCell : UITableViewCell

@property (class, nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, strong) id<RCMusicInfo> info;
// isDownload YES 下载 NO 删除
@property (nonatomic, copy) void(^downloadButtonClick)(NSString *_Nonnull musicId, BOOL isDownload);

@property (nonatomic, strong) UIImage *documentIcon;
@end

NS_ASSUME_NONNULL_END
