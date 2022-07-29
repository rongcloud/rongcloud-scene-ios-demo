
//
//  MHBeautyMenuCell.m


#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"
@interface MHBeautyMenuCell()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UIImageView *animationView;
@property (nonatomic, strong) UIImageView *selectedImgView;
@property (nonatomic, strong) UIButton *effectBtn;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIView * markView;
@property (nonatomic, strong) UIView * bgLabel;
@end
@implementation MHBeautyMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imgView];
        [self addSubview:self.beautyLabel];
    }
    return self;
}

- (void)setMenuModel:(MHBeautiesModel *)menuModel {
    if (!menuModel) {
        return;
    }
    self.bgLabel.hidden = YES;
    self.bgView.hidden = YES;
    _menuModel = menuModel;
    self.beautyLabel.text = YZMsg(menuModel.beautyTitle);
    if (menuModel.menuType == MHBeautyMenuType_Menu) {
        if ([menuModel.beautyTitle isEqualToString:@""]) {//仅限菜单页，@""的时候是相机功能
            self.beautyLabel.hidden = YES;
//            UIImage *img = BundleImg(@"cameraBG");
            UIImage * img  = BundleImg(@"beautyCamera")
            self.imgView.image = img;
            self.imgView.frame = CGRectMake((self.frame.size.width - 60)/2, (self.frame.size.height - 60)/2, 60, 60);
//            [self.imgView addSubview:self.animationView];
//            self.animationView.frame = CGRectMake(5, 5, 40, 40);
        }
        //短视频拍摄
        else if([menuModel.beautyTitle isEqualToString:@"单击拍"]){
            UIImage *img = [UIImage imageNamed:menuModel.imgName];
            self.imgView.image = img;
            self.imgView.frame = CGRectMake((self.frame.size.width - 60)/2, (self.frame.size.height - 60)/2, 60, 60);
            CGFloat bottom =  self.imgView.frame.origin.y + self.imgView.frame.size.height;
            CGRect rect = self.beautyLabel.frame;
            self.beautyLabel.frame = CGRectMake(rect.origin.x, bottom + 10, rect.size.width, rect.size.height);
            self.beautyLabel.text = @"";
            self.beautyLabel.hidden = YES;
        }
        else {
            for (UIView *subview in self.imgView.subviews){
                [subview removeFromSuperview];
            }
            self.imgView.image = BundleImg(menuModel.imgName);
            self.imgView.frame = CGRectMake((self.frame.size.width - 35)/2, self.isSimplification?(self.frame.size.height - 35)/2:15, 35, 35);
//            if (!self.isSimplification) {
                CGFloat bottom =  self.imgView.frame.origin.y + self.imgView.frame.size.height;
                CGRect rect = self.beautyLabel.frame;
                self.beautyLabel.frame = CGRectMake(rect.origin.x, bottom, rect.size.width, rect.size.height);
//                self.beautyLabel.hidden = NO;
//            }else{
//                self.beautyLabel.hidden = YES;
//            }
        }
    } else if (menuModel.menuType == MHBeautyMenuType_QuickBeauty || menuModel.menuType == MHBeautyMenuType_Specify || menuModel.menuType == MHBeautyMenuType_Filter){
        if (!_bgView) {
            _bgView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 50)/2, (self.frame.size.height - 60 - 15 )/2, 50, 75)];
//            _bgView.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:_bgView];
        }
        self.imgView.frame = CGRectMake(0,0, 50, 60);
        [_bgView addSubview:self.imgView];
        if (!_markView) {
            _markView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 75)];
            [_bgView addSubview:_markView];
        }
        if (!_bgLabel) {
            _bgLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 50, 15)];
            _bgLabel.backgroundColor = [UIColor whiteColor];
            [_bgView addSubview:_bgLabel];
        }
        self.bgLabel.hidden = NO;
        self.bgView.hidden = NO;
        self.selectedImgView.frame = CGRectMake((50-28)/2, (75-28)/2, 28, 28);
        CGFloat bottom =  _imgView.frame.origin.y + _imgView.frame.size.height;
        self.beautyLabel.frame = CGRectMake(0, bottom, 50, 15);
        
        self.beautyLabel.textColor = menuModel.isSelected ? [UIColor whiteColor] : FontColorBlackNormal1;
        _markView.backgroundColor = menuModel.isSelected ? [UIColor colorWithRed:0 green:0 blue:0 alpha:MHAlpha] : [UIColor clearColor];
        [_bgView bringSubviewToFront:self.beautyLabel];
        self.selectedImgView.hidden = !menuModel.isSelected;
        self.selectedImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.image = BundleImg(menuModel.imgName);
        [_markView addSubview:self.selectedImgView];
        [_bgView bringSubviewToFront:self.markView];
        [_bgView addSubview:self.beautyLabel];
    } /*else if ( ) {
        self.imgView.frame = CGRectMake((self.frame.size.width - 50)/2,(self.frame.size.height - 60 - 23)/2, 50, 60);
        CGFloat bottom =  _imgView.frame.origin.y + _imgView.frame.size.height;
        self.beautyLabel.frame = CGRectMake(3, bottom, self.frame.size.width - 6, 15);
        self.beautyLabel.textColor = menuModel.isSelected ? [UIColor whiteColor] : FontColorBlackNormal1;
        self.beautyLabel.backgroundColor = [UIColor whiteColor];
        self.selectedImgView.hidden = !menuModel.isSelected;
        self.selectedImgView.frame = self.imgView.frame;
        self.imgView.image = BundleImg(menuModel.imgName);
    }*/
    else if (menuModel.menuType == MHBeautyMenuType_Beauty || menuModel.menuType == MHBeautyMenuType_Face || menuModel.menuType == MHBeautyMenuType_Action || MHBeautyMenuType_MakeUp){
        self.imgView.frame = CGRectMake((self.frame.size.width - 40)/2, (self.frame.size.height - 40-23)/2, 40, 40);
        self.selectedImgView.hidden = YES;
        self.beautyLabel.textColor = menuModel.isSelected ? FontColorSelected : FontColorBlackNormal;
        if (menuModel.isSelected) {
            NSString *name = [NSString stringWithFormat:@"%@_selected",menuModel.imgName];
            UIImage *img = BundleImg(name);
            self.imgView.image = img;
        } else {
            self.imgView.image = BundleImg(menuModel.imgName);
        }
    } else if (menuModel.menuType == MHBeautyMenuType_Magnify){
        
        
    } else if (menuModel.menuType == MHBeautyMenuType_Watermark){
        self.imgView.frame = CGRectMake((self.frame.size.width - 40)/2, (self.frame.size.height - 40-23)/2, 40, 40);
        self.selectedImgView.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
        self.beautyLabel.textColor = menuModel.isSelected ? FontColorSelected : FontColorBlackNormal;
        if (menuModel.isSelected) {
            NSString *selectedImg = [NSString stringWithFormat:@"%@_selected",menuModel.imgName];
            [self.imgView setImage:[UIImage imageNamed:selectedImg]];
        } else {
            [self.imgView setImage:[UIImage imageNamed:menuModel.imgName]];
        }
    }
}
- (void)switchBeautyEffect:(BOOL)isSelected {
    self.beautyLabel.textColor = isSelected ? FontColorSelected : FontColorBlackNormal;
}
    

#pragma mark - lazy
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 40)/2, (self.frame.size.height - 40 -23)/2, 40, 40)];
    }
    return _imgView;
}
- (UILabel *)beautyLabel {
    if (!_beautyLabel) {
        CGFloat bottom =  _imgView.frame.origin.y + _imgView.frame.size.height;
        _beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, bottom+8, self.frame.size.width - 6, 15)];
        _beautyLabel.font = Font_10;
        _beautyLabel.textColor = [UIColor whiteColor];
        _beautyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _beautyLabel;
}

- (UIImageView *)animationView {
    if (!_animationView) {
        UIImage *img = BundleImg(@"cameraPoint");
        _animationView = [[UIImageView alloc] initWithImage:img];
        _animationView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _animationView;
}
    
- (UIImageView *)selectedImgView {
    if (!_selectedImgView) {
        UIImage *img = BundleImg(@"filter_selected2");
        _selectedImgView = [[UIImageView alloc] initWithImage:img];
        _selectedImgView.hidden = YES;
        [self addSubview:_selectedImgView];
    }
    return _selectedImgView;
}

@end
