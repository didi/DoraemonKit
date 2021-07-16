//
//  GIFInfoView.h
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/17.
//  Copyright © 2021 yixiang. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class GIFInfoView;

// 协议？没有实现具体定义
@protocol GIFInfoViewDelegate <NSObject>

@optional
// 点击关闭按钮
- (void)closeBtnClicked:(id)sender onColorPickInfoView:(GIFInfoView *)colorPickInfoView;

@end

@interface GIFInfoView : UIView

// 属性声明？property
@property (nonatomic, weak) id<GIFInfoViewDelegate> delegate;

// 设置timelast和帧数
- (void)setTimeLast:(NSString *)timeLast;
- (void)setFrameCount:(NSString *)frameCount;
- (void)setUrlInfo:(NSString *)UrlInfo;
- (void)setGifImageSize:(NSString *)GifImageSize;
@end

NS_ASSUME_NONNULL_END

