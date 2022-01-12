//
//  RCMusicToolBarAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicToolBarAppearance.h"
#import "RCMusicAppearanceData.h"

#define tba [RCMusicAppearanceData defaultAppearance].module.toolBar

@implementation RCMusicToolBarAppearance

- (instancetype)init {
    if (self = [super init]) {
        _leading = tba.leading ? tba.leading.floatValue : 14;
        _trailing = tba.leading ? tba.trailing.floatValue : -14;
        _spacing = tba.spacing ? tba.spacing.floatValue : 10;
        _turnOnSoundEffect = [tba.turnOnSoundEffect boolValue];
        _turnOnMusicControl = [tba.turnOnMusicControl boolValue];

        RCMusicBarItem *item1 = [RCMusicBarItem new];
        RCMusicIcon *icon1 = [RCMusicIcon new];
        icon1.local = @"local_music_normal_icon";
        icon1.remote = @"";
        RCMusicIcon *icon2= [RCMusicIcon new];
        icon2.local = @"local_music_selected_icon";
        icon2.remote = @"";
        item1.normalImage = icon1;
        item1.selectedImage = icon2;
        
        RCMusicBarItem *item2 = [RCMusicBarItem new];
        RCMusicIcon *icon3 = [RCMusicIcon new];
        icon3.local = @"remote_music_normal_icon";
        icon3.remote = @"";
        RCMusicIcon *icon4= [RCMusicIcon new];
        icon4.local = @"remote_music_selected_icon";
        icon4.remote = @"";
        item2.normalImage = icon3;
        item2.selectedImage = icon4;
        
        RCMusicBarItem *item3 = [RCMusicBarItem new];
        RCMusicIcon *icon5 = [RCMusicIcon new];
        icon5.local = @"music_control_normal_icon";
        icon5.remote = @"";
        RCMusicIcon *icon6= [RCMusicIcon new];
        icon6.local = @"music_control_selected_icon";
        icon6.remote = @"";
        item3.normalImage = icon5;
        item2.selectedImage = icon6;
        
        RCMusicBarItem *item4 = [RCMusicBarItem new];
        RCMusicIcon *icon7 = [RCMusicIcon new];
        icon7.local = @"music_control_normal_icon";
        icon7.remote = @"";
        RCMusicIcon *icon8= [RCMusicIcon new];
        icon8.local = @"music_control_selected_icon";
        icon8.remote = @"";
        item4.normalImage = icon7;
        item4.selectedImage = icon8;
        
        _items = tba.items ? tba.items : @[item1,item2,item3,item4];
        
        self.backgroundColor = tba.backgroundColor ? tba.backgroundColor.appearanceValue : [UIColor clearColor];
    }
    return self;
}
@end
