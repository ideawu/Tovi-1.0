//
//  ToviWebProxy.h
//  Tovi
//
//  Created by ideawu on 13-3-31.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ToviWebView;

@interface ToviWebProxy : NSObject

@property (weak) ToviWebView *webView;

- (void)openfile:(NSString *)filename scandir:(BOOL)scandir;
- (void)openfiles:(NSArray *)files;
- (void)openfiles:(NSArray *)files seekToFile:(NSString *)theFile;

- (void)sendKeyDown: (int)code;
- (void)reloadFiles;

- (NSString *)currentFile;
- (void)changeTheme:(NSString *)themeName;
- (void)webViewResize:(NSSize)size;
- (void)rotate:(int)degree;

@end
