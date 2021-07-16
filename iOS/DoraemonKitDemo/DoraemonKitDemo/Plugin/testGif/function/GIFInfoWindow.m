//
//  GIFInfoWindow.m
//  DoraemonKitDemo
//
//  Created by 宋迪 on 2021/5/17.
//  Copyright © 2021 yixiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GIFInfoWindow.h"
#import "GIFInfoView.h"
#import "DoraemonDefine.h"

@interface GIFInfoController: UIViewController

@end

@implementation GIFInfoController
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.view.window.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(100), DoraemonScreenHeight - (size.height < size.width ? size.height : size.width) - kDoraemonSizeFrom750_Landscape(100), size.height, size.width);
//    });
//}
@end

@interface GIFInfoWindow () <GIFInfoViewDelegate>

@property (nonatomic, strong) GIFInfoView *pickInfoView;

@end

@implementation GIFInfoWindow

#pragma mark - Lifecycle

+ (GIFInfoWindow *)shareInstance{
    static dispatch_once_t once;
    static GIFInfoWindow *instance;
    dispatch_once(&once, ^{
        instance = [[GIFInfoWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (kInterfaceOrientationPortrait) {
        self = [super initWithFrame:CGRectMake(kDoraemonSizeFrom750_Landscape(30), DoraemonScreenHeight - kDoraemonSizeFrom750_Landscape(300) - kDoraemonSizeFrom750_Landscape(10) - IPHONE_SAFEBOTTOMAREA_HEIGHT, DoraemonScreenWidth - 2*kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(300))];
    } else {
        self = [super initWithFrame:CGRectMake(kDoraemonSizeFrom750_Landscape(30), DoraemonScreenHeight - kDoraemonSizeFrom750_Landscape(100) - kDoraemonSizeFrom750_Landscape(30) - IPHONE_SAFEBOTTOMAREA_HEIGHT, DoraemonScreenHeight - 2*kDoraemonSizeFrom750_Landscape(30), kDoraemonSizeFrom750_Landscape(100))];
    }
    
    if (self) {
        #if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
                    if (windowScene.activationState == UISceneActivationStateForegroundActive){
                        self.windowScene = windowScene;
                        break;
                    }
                }
            }
        #endif
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        if (!self.rootViewController) {
            self.rootViewController = [[GIFInfoController alloc] init];
        }
        
        GIFInfoView *pickInfoView = [[GIFInfoView alloc] initWithFrame:self.bounds];
        pickInfoView.delegate = self;
        [self.rootViewController.view addSubview:pickInfoView];
        self.pickInfoView = pickInfoView;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePlugin:) name:DoraemonClosePluginNotification object:nil];
    }
    return self;
}

#pragma mark - Public

- (void)show{
    self.hidden = NO;
}

- (void)hide{
    self.hidden = YES;
}


- (void)setTimeLast:(NSString *)timeLast{
    [self.pickInfoView setTimeLast:timeLast];
}

- (void)setFrameCount:(NSString *)frameCount{
    [self.pickInfoView setFrameCount:frameCount];
}

- (void)setUrlInfo:(NSString *)UrlInfo{
    [self.pickInfoView setUrlInfo:UrlInfo];
}

- (void)setGifImageSize:(NSString *)GifImageSize{
    [self.pickInfoView setGifImageSize:GifImageSize];
}
 
#pragma mark GIFInfoViewDelegate

- (void)closeBtnClicked:(id)sender onColorPickInfoView:(GIFInfoView *)colorPickInfoView {
    [[NSNotificationCenter defaultCenter] postNotificationName:DoraemonClosePluginNotification object:nil userInfo:nil];
}

#pragma mark - Notification

- (void)closePlugin:(NSNotification *)notification{
    [self hide];
}


@end
