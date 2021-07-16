//
//  GIFInfoWindow.h
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/17.
//  Copyright © 2021 yixiang. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GIFInfoWindow : UIWindow

+ (GIFInfoWindow *)shareInstance;

- (void)show;

- (void)hide;

- (void)setTimeLast:(NSString *)timeLast;
- (void)setFrameCount:(NSString *)frameCount;
- (void)setUrlInfo:(NSString *)UrlInfo;
- (void)setGifImageSize:(NSString *)GifImageSize;
@end

NS_ASSUME_NONNULL_END
