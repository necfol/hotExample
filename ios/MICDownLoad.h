//
//  MICDownLoad.h
//  hotExample
//
//  Created by necfol on 4/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//


#import <Foundation/Foundation.h>
typedef void(^CallbackBlock) (NSInteger status,id data);

@interface MICDownLoad : NSObject <NSURLSessionDelegate>

+(instancetype)download;
-(void)downloadFileWithURLString:(NSString*)urlString callback:(CallbackBlock)callback;

@end

