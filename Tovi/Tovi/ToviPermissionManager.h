//
//  ToviPermissionManager.h
//  Tovi
//
//  Created by ideawu on 13-4-20.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToviPermissionManager : NSObject{
}

+ (NSDictionary *)urls;

+ (void)accquireAll;
+ (void)releaseAll;

+ (void)addPath:(NSString *)path;
+ (void)removePath:(NSString *)path;

@end
