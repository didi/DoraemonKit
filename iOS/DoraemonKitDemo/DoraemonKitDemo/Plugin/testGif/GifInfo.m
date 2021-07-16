//
//  GifInfo.m
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/30.
//  Copyright © 2021 yixiang. All rights reserved.
//

#import "GifInfo.h"
#import "UIImageView+GIFProperty.h"
#import "DoraemonHomeWindow.h"
#import "GIFInfoWindow.h"
#import "GIFInfoView.h"
#import "UIWebViewDemo.h"

@implementation GifInfo
    UIWebView *webview1;
- (void)pluginDidLoad {
    [super viewDidLoad];
    //[[DoraemonColorPickWindow shareInstance] show];
    [[GIFInfoWindow shareInstance] show];
    [[DoraemonHomeWindow shareInstance] hide];
    NSLog(@"what?");
    UIViewController *vc = [[UIWebViewDemo alloc] init];
    [DoraemonHomeWindow openPlugin:vc];
    
}
- (void)openUIWebView{
    UIViewController *vc = [[UIWebViewDemo alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
