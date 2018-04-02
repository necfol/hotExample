/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "MICGetBundle.h"
#import "MICShouldUpdate.h"
#import "MICDownLoad.h"
#import "SSZipArchive.h"
#import "DiffMatchPatch.h"

@interface AppDelegate()
@property (nonatomic,strong) RCTBridge *bridge;
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  jsCodeLocation = [MICGetBundle getBundle];
  _bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                  moduleProvider:nil
                                   launchOptions:launchOptions];
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:_bridge
                                                   moduleName:@"hotExample"
                                            initialProperties:nil];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
  [MICShouldUpdate shouldUpdate:^(NSInteger status, id datas) {
    NSLog(@"==============123");
    if(status == 1){
    NSLog(@"==============567");
      [[MICDownLoad download] downloadFileWithURLString:datas[@"zip"] callback:^(NSInteger status, id data) {
        if(status == 1){
          NSError *error;
          NSString *filePath = (NSString *)data;
          NSString *desPath = [NSString stringWithFormat:@"%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
          [SSZipArchive unzipFileAtPath:filePath toDestination:desPath overwrite:YES password:nil error:&error];
          NSLog(@"filePath=======%@", filePath);
          NSLog(@"desPath=======%@", desPath);
          if(!error){
            NSString *diffPath = [NSString stringWithFormat:@"%@%@", desPath, @"/diff.bundle"];
            NSString *jsCodeLocationPath = [NSString stringWithFormat:@"%@/\%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],@"main.bundle"];
            NSString *diffCode = [NSString stringWithContentsOfFile:diffPath encoding:NSUTF8StringEncoding error:nil];
            NSString *jsCodeLocation = [NSString stringWithContentsOfFile:jsCodeLocationPath encoding:NSUTF8StringEncoding error:nil];
            
            DiffMatchPatch *diffMatchPatch = [[DiffMatchPatch alloc] init];
            NSError *error;
            NSArray *patches = [diffMatchPatch patch_fromText:diffCode error:&error];
            if (error != nil) {
              NSLog(@"diff match failed : %@", error);
            }
            NSArray *resultsArray = [diffMatchPatch patch_apply:patches toString:jsCodeLocation];
            NSString *resultJSCode = resultsArray[0]; //patch合并后的js
            NSLog(@"=====================%@",resultJSCode);
            [resultJSCode writeToFile:jsCodeLocationPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Version" ofType:@"plist"];
            NSMutableDictionary *newsDict = [NSMutableDictionary dictionary];
            [newsDict setObject:datas[@"version"] forKey:@"version"];
            [newsDict writeToFile:filePath atomically:YES];
            NSLog(@"解压成功");
            //            如果是立马更新则打开下面代码
            //            [_bridge reload];
          }else{
            NSLog(@"解压失败");
          }
        }
      }];
    }
  }];
}
@end
