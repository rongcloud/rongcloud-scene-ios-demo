//
//  RCMusicControlCell.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import "RCMusicControlCell.h"
#import <Masonry/Masonry.h>
#import "RCMusicControlAppearance.h"

@interface RCMusicControlCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UISlider *rcmSlider;
@property (nonatomic, strong) UISwitch *rcmSwitch;
@property (nonatomic, strong) RCMusicControlAppearance *appearance;
@end

@implementation RCMusicControlCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self buildLayout];
    }
    return self;
}

- (void)sliderValueChange:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    self.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)slider.value];
}

- (void)sliderValueUpdate:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    self.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)slider.value];
    if (self.controlAction) {
        self.controlAction(self.cellStyle, self.cellData[@"text"], (NSInteger)slider.value);
    }
}

- (void)switchValueUpdate:(UISwitch *)_switch {
    if (self.controlAction) {
        NSInteger value = _switch.on ? 1 : 0;
        self.controlAction(self.cellStyle, self.cellData[@"text"], value);
    }
}

- (void)buildLayout {
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView).offset(-20);
        make.leading.equalTo(self.contentView).offset(20);
    }];
    
    [self.contentView addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView).offset(-20);
        make.trailing.equalTo(self.contentView).offset(-20);
    }];
    
    [self.contentView addSubview:self.rcmSlider];
    [self.rcmSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel.mas_trailing).offset(20);
        make.trailing.equalTo(self.valueLabel.mas_leading).offset(-20);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.rcmSwitch];
    [self.rcmSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-20);
    }];
}

- (void)setCellStyle:(RCMusicControlCellStyle)cellStyle {
    _cellStyle = cellStyle;
    self.rcmSlider.hidden = cellStyle == RCMusicControlCellStyleSwitch;
    self.valueLabel.hidden = self.rcmSlider.hidden;
    self.rcmSwitch.hidden = !self.rcmSlider.hidden;
}

- (void)setCellData:(NSDictionary *)cellData {
    _cellData = cellData;
    self.titleLabel.text = cellData[@"text"];
    self.valueLabel.text = [cellData[@"value"] stringValue];
    self.rcmSlider.value = [cellData[@"value"] floatValue];
    self.rcmSwitch.on = NO;
}
+ (NSString *)identifier {
    return @"RCMusicControlCellIdentifier";
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = self.appearance.font;
        _titleLabel.textColor = self.appearance.textColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = @"本端音量";
    }
    return _titleLabel;
}

- (UILabel *)valueLabel {
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = self.appearance.font;
        _valueLabel.textColor = self.appearance.textColor;
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.text = @"100";
    }
    return _valueLabel;
}

- (UISlider *)rcmSlider {
    if (_rcmSlider == nil) {
        _rcmSlider = [[UISlider alloc] init];
        _rcmSlider.minimumValue = 0;
        _rcmSlider.maximumValue = 100;
        _rcmSlider.value = 100;
        _rcmSlider.tintColor = self.appearance.tintColor;
        [_rcmSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        [_rcmSlider addTarget:self action:@selector(sliderValueUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rcmSlider;
}

- (UISwitch *)rcmSwitch {
    if (_rcmSwitch == nil) {
        _rcmSwitch = [[UISwitch alloc] init];
        _rcmSwitch.tintColor = self.appearance.tintColor;
        _rcmSwitch.onTintColor = self.appearance.tintColor;
        [_rcmSwitch addTarget:self action:@selector(switchValueUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rcmSwitch;
}

- (RCMusicControlAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicControlAppearance alloc] init];
    }
    return _appearance;
}
@end
