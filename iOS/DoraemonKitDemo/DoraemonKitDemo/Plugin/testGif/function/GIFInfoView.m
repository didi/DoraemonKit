//
//  GIFInfoView.m
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/17.
//  Copyright © 2021 yixiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIFInfoView.h"
#import "DoraemonDefine.h"

@interface GIFInfoView ()

@property (nonatomic, strong) UILabel *timelastLbl;
@property (nonatomic, strong) UILabel *framcountLbl;
@property (nonatomic, strong) UILabel *urlinfoLbl;
@property (nonatomic, strong) UILabel *gifimagesizeLbl;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation GIFInfoView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            } else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
    } else {
#endif
        self.backgroundColor = [UIColor whiteColor];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    }
#endif
    self.layer.cornerRadius = kDoraemonSizeFrom750_Landscape(8);
    self.layer.borderWidth = 1.;
    self.layer.borderColor = [UIColor doraemon_colorWithHex:0x999999 andAlpha:0.2].CGColor;
    
    //[self addSubview:self.colorView];
    [self addSubview:self.timelastLbl];
    [self addSubview:self.framcountLbl];
    [self addSubview:self.urlinfoLbl];
    [self addSubview:self.gifimagesizeLbl];
    [self addSubview:self.closeBtn];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [self.closeBtn setImage:[UIImage doraemon_xcassetImageNamed:@"doraemon_close_dark"] forState:UIControlStateNormal];
            } else {
                [self.closeBtn setImage:[UIImage doraemon_xcassetImageNamed:@"doraemon_close"] forState:UIControlStateNormal];
            }
        }
    }
#endif
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat colorWidth = kDoraemonSizeFrom750_Landscape(28);
//    CGFloat colorHeight = kDoraemonSizeFrom750_Landscape(28);
//    self.colorView.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(32), (self.doraemon_height - colorHeight) / 2.0, colorWidth, colorHeight);
    
    CGFloat colorValueWidth = kDoraemonSizeFrom750_Landscape(400);
    self.timelastLbl.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(-100), colorValueWidth, self.doraemon_height);
    self.framcountLbl.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(-50), colorValueWidth, self.doraemon_height);
    self.urlinfoLbl.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(70), kDoraemonSizeFrom750_Landscape(600), self.doraemon_height);
    self.gifimagesizeLbl.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(0), colorValueWidth, self.doraemon_height);
    
    CGFloat closeWidth = kDoraemonSizeFrom750_Landscape(44);
    CGFloat closeHeight = kDoraemonSizeFrom750_Landscape(44);
    self.closeBtn.frame = CGRectMake(self.doraemon_width - closeWidth - kDoraemonSizeFrom750_Landscape(32), (self.doraemon_height - closeHeight) / 2.0, closeWidth, closeHeight);
}

#pragma mark - Public

- (void)setTimeLast:(NSString *)timeLast{
    self.timelastLbl.text = timeLast;
}

- (void)setFrameCount:(NSString *)frameCount{
    self.framcountLbl.text = frameCount;
}

- (void)setUrlInfo:(NSString *)UrlInfo{
    self.urlinfoLbl.text = UrlInfo;
}

- (void)setGifImageSize:(NSString *)GifImageSize{
    self.gifimagesizeLbl.text = GifImageSize;
}
#pragma mark - Actions

- (void)closeBtnClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeBtnClicked:onColorPickInfoView:)]) {
        [self.delegate closeBtnClicked:sender onColorPickInfoView:self];
    }
}



#pragma mark - Getter


- (UILabel *)timelastLbl {
    if (!_timelastLbl) {
        _timelastLbl = [[UILabel alloc] init];
        _timelastLbl.textColor = [UIColor doraemon_black_1];
        _timelastLbl.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750_Landscape(28)];
    }
    return _timelastLbl;
}

- (UILabel *)framcountLbl {
    if (!_framcountLbl) {
        _framcountLbl = [[UILabel alloc] init];
        _framcountLbl.textColor = [UIColor doraemon_black_1];
        _framcountLbl.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750_Landscape(28)];
    }
    return _framcountLbl;
}

- (UILabel *)urlinfoLbl {
    if (!_urlinfoLbl) {
        _urlinfoLbl = [[UILabel alloc] init];
        _urlinfoLbl.textColor = [UIColor doraemon_black_1];
        _urlinfoLbl.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750_Landscape(28)];
        _urlinfoLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _urlinfoLbl.numberOfLines = 0;
    }
    return _urlinfoLbl;
}
- (UILabel *)gifimagesizeLbl {
    if (!_gifimagesizeLbl) {
        _gifimagesizeLbl = [[UILabel alloc] init];
        _gifimagesizeLbl.textColor = [UIColor doraemon_black_1];
        _gifimagesizeLbl.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750_Landscape(28)];
    }
    return _gifimagesizeLbl;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        UIImage *closeImage = [UIImage doraemon_xcassetImageNamed:@"doraemon_close"];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        if (@available(iOS 13.0, *)) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                closeImage = [UIImage doraemon_xcassetImageNamed:@"doraemon_close_dark"];
            }
        }
#endif
        [_closeBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
