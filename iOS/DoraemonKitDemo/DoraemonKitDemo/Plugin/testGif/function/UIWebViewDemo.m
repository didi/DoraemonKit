//
//  UIWebViewDemo.m
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/18.
//  Copyright © 2021 yixiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIWebViewDemo.h"
#import "UIImageView+GIFProperty.h"
#import "GIFInfoView.h"
#import "GIFInfoWindow.h"
@interface UIWebViewDemo()<UITableViewDelegate, UITableViewDataSource>

@end
@implementation UIWebViewDemo
    UIWebView *webview2;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = DoraemonDemoLocalizedString(@"UIWebView");
    webview2 = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webview2 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://card.weibo.com/article/m/show/id/2309404225092568618984"]]];
    //添加长摁识别手势
    UILongPressGestureRecognizer * longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [webview2 addGestureRecognizer:longPressed];
    [self.view addSubview:webview2];
}
//- (void)openUIWebView{
//    UIViewController *vc = [[UIWebViewDemo alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}
- (void)longPressed:(UITapGestureRecognizer*)recognizer{
//只在长按手势开始的时候才去获取图片的url
    if (recognizer.state != UIGestureRecognizerStateBegan) {
    return;
    }
    CGPoint touchPoint = [recognizer locationInView:webview2];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [webview2 stringByEvaluatingJavaScriptFromString:js];
    if (urlToSave.length == 0) {
        NSLog(@"获取图片失败");
        NSString *stringframecount = @"";
        NSString *stringtimelast = @"获取图片失败";
        [[GIFInfoWindow shareInstance] setTimeLast:stringtimelast];
        [[GIFInfoWindow shareInstance] setFrameCount:stringframecount];
        return;
    }
    NSLog(@"获取到图片1地址：%@",urlToSave);
    NSString *fileURL = urlToSave;
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
//    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"variableDuration" ofType:@"gif"]];
    UIImageView *gifimage = [[UIImageView alloc] init];
    //获取gif的信息
    UIImage *imagesize = [UIImage imageWithData:urlData];
    NSLog(@"===%f===%f",imagesize.size.width,imagesize.size.height);
    NSString *stringimagesize = [NSString stringWithFormat:@"长：%d，宽：%d",(int)imagesize.size.width,(int)imagesize.size.height];
    NSString *stringurlinfo = [NSString stringWithFormat:@"图片地址：%@",urlToSave];
    NSTimeInterval  signSuccessGifImg = [gifimage durationForGifData:urlData];
    //获取gif执行时间
    NSInteger GifImgTimelast = [gifimage repeatCountForGifData:urlData];
    //获取gif的帧数
    NSInteger gifframecount = [gifimage GifFrameCount:urlData];
    NSLog(@"%ld",gifframecount);
    NSLog(@"%f",signSuccessGifImg);
    NSLog(@"%ld",GifImgTimelast);
    NSString *stringframecount = [NSString stringWithFormat:@"%ld",gifframecount];
    stringframecount = [[NSString alloc] initWithFormat:@"帧数：%@",stringframecount];
    NSString *stringtimelast = [NSString stringWithFormat:@"%f",signSuccessGifImg];
    stringtimelast = [[NSString alloc] initWithFormat:@"持续时间：%@s",stringtimelast];
    [[GIFInfoWindow shareInstance] setTimeLast:stringtimelast];
    [[GIFInfoWindow shareInstance] setFrameCount:stringframecount];
    [[GIFInfoWindow shareInstance] setUrlInfo:stringurlinfo];
    [[GIFInfoWindow shareInstance] setGifImageSize:stringimagesize];

    
}

@end
