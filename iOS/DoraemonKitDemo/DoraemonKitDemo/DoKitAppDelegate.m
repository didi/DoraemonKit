//
//  AppDelegate.m
//  DoraemonKitDemo
//
//  Created by yixiang on 2017/12/11.
//  Copyright © 2017年 yixiang. All rights reserved.
//

#import "DoKitAppDelegate.h"
#import <DoraemonKit/DoraemonKit.h>
#import "DoraemonDemoHomeViewController.h"
#import "DoraemonTimeProfiler.h"
//#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DoraemonUtil.h"
#import "SDImageWebPCoder.h"
#import <DoraemonKit/DoraemonAppInfoViewController.h>
#import <fmdb/FMDB.h>

#if __has_include(<FBRetainCycleDetector/FBRetainCycleDetector.h>)
#define XXX 1
#else
#define XXX 2
#endif

@interface DoKitAppDelegate ()

@end

@implementation DoKitAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[DoraemonTimeProfiler startRecord];
    
//    id a = [[NSObject alloc] init];
//    [a b];
    
    //[[self class] handleCCrashReportWrap];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    for (int i=0; i<10; i++) {
        //DDLogInfo(@"点击添加埋点11111");
    }
    [[DoraemonManager shareInstance] addPluginWithTitle:DoraemonDemoLocalizedString(@"测试插件") icon:@"doraemon_default" desc:DoraemonDemoLocalizedString(@"测试插件") pluginName:@"TestPlugin" atModule:DoraemonDemoLocalizedString(@"业务工具")];

    [[DoraemonManager shareInstance] addPluginWithTitle:DoraemonDemoLocalizedString(@"GifInfo") icon:@"doraemon_default" desc:DoraemonDemoLocalizedString(@"GIF图片信息显示插件") pluginName:@"GifInfo" atModule:DoraemonDemoLocalizedString(@"业务工具")];
    
    [[DoraemonManager shareInstance] addPluginWithTitle:DoraemonDemoLocalizedString(@"block方式加入插件") icon:@"doraemon_default" desc:@"测试插件" pluginName:@"pluginName" atModule:DoraemonDemoLocalizedString(@"业务工具") handle:^(NSDictionary *itemData) {
        NSLog(@"handle block plugin");
    }];
    
    [[DoraemonManager shareInstance] addPluginWithTitle:@"自定图标" image:[UIImage imageNamed:@"zhaoliyin"] desc:@"自定义图标" pluginName:@"自定图标" atModule:DoraemonDemoLocalizedString(@"业务工具") handle:nil];

    //测试 a49842eeebeb1989b3f9565eb12c276b
    //线上 749a0600b5e48dd77cf8ee680be7b1b7
    //[DoraemonManager shareInstance].pId = @"749a0600b5e48dd77cf8ee680be7b1b7";
    [[DoraemonManager shareInstance] addStartPlugin:@"StartPlugin"];
    [DoraemonManager shareInstance].bigImageDetectionSize = 10 * 1024;//大图检测只检测10K以上的
    [DoraemonManager shareInstance].startClass = @"DoKitAppDelegate";
    //[DoraemonManager shareInstance].autoDock = NO;
    [[DoraemonManager shareInstance] installWithPid:@"749a0600b5e48dd77cf8ee680be7b1b7"];
    //[[DoraemonManager shareInstance] installWithStartingPosition:CGPointMake(66, 66)];
    
    [[DoraemonManager shareInstance] addANRBlock:^(NSDictionary *anrDic) {
        NSLog(@"anrDic == %@",anrDic);
    }];

    [[DoraemonManager shareInstance] addH5DoorBlock:^(NSString *h5Url) {
        NSLog(@"使用自带容器打开H5链接: %@",h5Url);
    }];
    
    [[DoraemonManager shareInstance] addWebpHandleBlock:^UIImage * _Nullable(NSString * _Nonnull filePath) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        UIImage *image = [[SDImageWebPCoder sharedCoder] decodedImageWithData:data options:nil];
        return image;
    }];
    // 例子：移除 GPS Mock
//    [[DoraemonManager shareInstance] installWithCustomBlock:^{
//        [[DoraemonManager shareInstance] removePluginWithPluginName:@"DoraemonGPSPlugin" atModule:@"常用工具"];
//    }];

    for (int i=0; i<10; i++) {
       // DDLogInfo(@"点击添加埋点22222");
    }
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    DoraemonDemoHomeViewController *homeVc = [[DoraemonDemoHomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeVc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    NSArray *array = @[];
    NSLog(@"%@",[array description]);
    
    //[DoraemonTimeProfiler stopRecord];
    
    [self test];
    
    [self createTestDatabase];
    
    return YES;
}

- (void)test{
    [self test2];
    
    DoraemonAppInfoViewController.customAppInfoBlock = ^(NSMutableArray<NSDictionary *> *appInfos) {
        [appInfos addObject:@{@"title": @"Build Time", @"value": @"2020-05-21 11:29:22"}];
        [appInfos addObject:@{@"title": @"Commit", @"value": @"1ffa9c6"}];
        [appInfos addObject:@{@"title": @"Branch", @"value": @"version/1.2.0"}];
    };
}

- (void)test2{
    NSDictionary *dic = @{
        @"name":@"yixiang"
    }.mutableCopy;
    [dic setValue:@"caoweoweo" forKey:@"name"];
    NSLog(@"a == %@",dic);
}

- (void)createTestDatabase {
    NSString *rootPath = NSHomeDirectory();
    NSString *dBPath = [NSString stringWithFormat:@"%@/Documents/dokit_test_database.sqlite", rootPath];
    FMDatabase *db;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dBPath]) {
        db = [FMDatabase databaseWithPath:dBPath];
        db.shouldCacheStatements = YES;
        
        if ([db open]) {
            NSString *sql_1 = @"CREATE TABLE IF NOT EXISTS dokit_records_table (id INTEGER PRIMARY KEY, record TEXT, record_2 INTEGER);";
            [db executeUpdate:sql_1];
            
//            NSString *sql_2 = @"CREATE TABLE IF NOT EXISTS dokit_records_table_2 (id_2 INTEGER PRIMARY KEY AUTOINCREMENT, record_2 TEXT);";
//            [db executeUpdate:sql_2];
            
//            NSString *sql_3 = @"SELECT * FROM sqlite_master WHERE type='table' ORDER BY name;";
//            FMResultSet *set = [db executeQuery:sql_3];
//            while ([set next]) {
//                NSString *name = [set stringForColumnIndex:1];
//                NSLog(@"-=-=-=- name = %@", name);
//            }

            [db close];
        }
    }
}

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

+(void) handleCCrashReportWrap{    
//    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType: PLCrashReporterSignalHandlerTypeMach symbolicationStrategy: PLCrashReporterSymbolicationStrategyAll];
//    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
//
//    NSError *error;
//
//    // Check if we previously crashed
//    if ([crashReporter hasPendingCrashReport])
//        [self handleCCrashReport:crashReporter ];
//
//    // Enable the Crash Reporter
//    if (![crashReporter enableCrashReporterAndReturnError: &error])
//        NSLog(@"Warning: Could not enable crash reporter: %@", error);
}

//+ (void) handleCCrashReport:(PLCrashReporter * ) crashReporter{
//    NSData *crashData;
//    NSError *error;
//    
//    // Try loading the crash report
//    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
//    if (crashData == nil) {
//        NSLog(@"Could not load crash report: %@", error);
//        [crashReporter purgePendingCrashReport];
//        return;
//    }
//    
//    // We could send the report from here, but we'll just print out
//    // some debugging info instead
//    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error] ;
//    
//    if (report == nil) {
//        NSLog(@"Could not parse crash report");
//        [crashReporter purgePendingCrashReport];
//        return;
//    }
//    
//    //    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
//    //    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
//    //          report.signalInfo.code, report.signalInfo.address);
//    
//    // Purge the report
//    [crashReporter purgePendingCrashReport];
//    
////    *     //上传--这后面的代码是我加的.
//       NSString *humanText = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];
//    NSLog(@"yixiang crash == %@",humanText);
////    *
////    *     [self uploadCrashLog:@"c crash" crashContent:humanText withSuccessBlock:^{
////        *     }];//uploadCrashLog这个函数是把log文件上传服务器的,请自行补充哈;还可以写入沙盒,供自己就地查看,下面是写入沙盒的代码
////    *
////    *     NSString * documentDic = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
////    *     NSString * fileName = [documentDic stringByAppendingPathComponent:@"1.crash"];
////    *     NSError * err = nil;
////    *     [humanText writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&err];
////    return;
//
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
