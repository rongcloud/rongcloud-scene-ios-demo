//
//  RCMusicRemoteListCell.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import "RCMusicRemoteListCell.h"
#import "RCMusicListAppearance.h"
#import "RCMusicResponse.h"
#import <Masonry/Masonry.h>
#import "UIImageView+WebCache.h"
#import "RCMusicDefine.h"
#import "UIImage+RCMBundle.h"
#import "NSString+RCMMD5.h"

@interface RCMusicRemoteListCell ()
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *fileSizeLabel;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) RCMusicListAppearance *appearance;
@end

@implementation RCMusicRemoteListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.appearance = [[RCMusicListAppearance alloc] initWithDictionary:@{}];
        [self buildLayout];
    }
    return self;
}

#pragma mark - BUTTON CLICK

- (void)buttonClick:(UIButton *)button {
    if (self.downloadButtonClick) {
        self.downloadButtonClick(self.info.musicId, !button.selected);
    }
}

#pragma mark -LAYOUT SUBVIEWS

- (void)buildLayout {
    [self.contentView addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10 + self.appearance.avatarInsets.top);
        make.leading.equalTo(self.contentView).offset(20 + self.appearance.avatarInsets.left + self.appearance.avatarInsets.right);
        make.bottom.equalTo(self.contentView).offset(-10 + self.appearance.avatarInsets.bottom);
        make.size.mas_equalTo(self.appearance.avatarSize);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        make.top.equalTo(self.contentView).offset(6);
        make.trailing.equalTo(self.contentView).offset(10);
    }];
    
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        make.centerY.equalTo(self.avatarView);
        make.trailing.equalTo(self.contentView).offset(-10);
    }];
    
    [self.contentView addSubview:self.fileSizeLabel];
    [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.trailing.equalTo(self.contentView).offset(-6);
    }];
    
    [self.contentView addSubview:self.downloadButton];
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatarView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.trailing.equalTo(self.contentView).offset(-20);
    }];
    
}

#pragma mark -SETTER

- (void)setInfo:(id<RCMusicInfo>)info {
    if (info.coverUrl != nil) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:info.coverUrl] placeholderImage:[UIImage rcm_imageNamed:@"music_placeholder"] options:SDWebImageQueryDiskDataSync completed:nil];
    } else {
        NSLog(@"歌曲封面图片为空");
    }
    
    self.titleLabel.text = info.musicName ?: @"";
    self.subTitleLabel.text = info.author ?: @"";
    self.fileSizeLabel.text = info.albumName ?: @"";
    self.downloadButton.selected = [info.isLocal boolValue];
}

- (void)setDocumentIcon:(UIImage *)documentIcon {
    self.avatarView.image = documentIcon;
}
#pragma mark -GETTER

+ (NSString *)identifier {
    return @"RCMusicRemoteListCellIdentifier";
}

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 22.0f;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = self.appearance.titleLabelTextColor;
        _titleLabel.font = self.appearance.titleLabelFont;
        _titleLabel.textAlignment = self.appearance.titleLabelTextAlignment;
    }
    return _titleLabel;
}

-(UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = self.appearance.subTitleLabelTextColor;
        _subTitleLabel.font = self.appearance.subTitleLabelFont;
        _subTitleLabel.textAlignment = self.appearance.subTitleLabelTextAlignment;
    }
    return _subTitleLabel;
}

-(UILabel *)fileSizeLabel {
    if (_fileSizeLabel == nil) {
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.textColor = self.appearance.fileSizeLabelTextColor;
        _fileSizeLabel.font = self.appearance.fileSizeLabelFont;
        _fileSizeLabel.textAlignment = self.appearance.fileSizeLabelTextAlignment;
    }
    return _fileSizeLabel;
}

- (UIButton *)downloadButton {
    if (_downloadButton == nil) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.contentMode = UIViewContentModeScaleAspectFit;
        [_downloadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton setImage:[UIImage rcm_imageNamed:@"add_music_icon"] forState:UIControlStateNormal];
        [_downloadButton setImage:[UIImage rcm_imageNamed:@"added_music_icon"] forState:UIControlStateSelected];
    }
    return _downloadButton;
}

@end
