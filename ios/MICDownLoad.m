//
//  MICDownLoad.m
//  hotExample
//
//  Created by necfol on 4/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "MICDownLoad.h"

@implementation MICDownLoad

+(instancetype)download {
  static MICDownLoad *downloadMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    downloadMyManager = [[self alloc] init];
  });
  return downloadMyManager;
}

-(void)downloadFileWithURLString:(NSString *)urlString callback:(CallbackBlock)callback {
  NSURL * url = [NSURL URLWithString:urlString];
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
  NSURLSessionDownloadTask * downloadTask =[defaultSession downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
  {
    if(error == nil)
    {
      NSError *err = nil;
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSString *Dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      NSString *filePath = [NSString stringWithFormat:@"%@/\%@",Dir,@"bundle.zip"];
      NSURL *DirURL = [NSURL fileURLWithPath:filePath];
      if([fileManager fileExistsAtPath:filePath]){
        [fileManager removeItemAtURL:DirURL error:nil];
      }
      if ([fileManager moveItemAtURL:location
                               toURL:DirURL
                               error: &err])
      {
        callback(1,filePath);
      }
      else
      {
        callback(0,nil);
      }
    }
  }];
  [downloadTask resume];
  
}
@end

