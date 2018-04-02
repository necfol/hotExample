//
//  MICShouldUpdate.h
//  hotExample
//
//  Created by necfol on 4/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CallbackBlock) (NSInteger status,id data);

@interface MICShouldUpdate : NSObject

+(void)shouldUpdate:(CallbackBlock)callback;
@end
