//
//  UIImageView+GIFProperty.h
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/16.
//  Copyright © 2021 yixiang. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (GIFProperty)
-(NSTimeInterval)durationForGifData:(NSData *)data;//获取gif动画总时长
-(NSInteger)repeatCountForGifData:(NSData *)data;//获取gif动画循环总次数 0:表示无限循环
-(NSInteger)GifFrameCount:(NSDate *)data;
@end

NS_ASSUME_NONNULL_END
