//
//  MHMakeUpView.h
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MHMakeUpViewDelegate <NSObject>
- (void)handleMakeUpType:(NSInteger)type withON:(BOOL)On;
@end

@interface MHMakeUpView : UIView

@property (nonatomic, weak) id <MHMakeUpViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
