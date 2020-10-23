//
//  ToviWindowController.h
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class ToviAppDelegate;
@class ToviWebView;

@interface ToviWindowController : NSWindowController<NSWindowDelegate>{
}
@property (weak) IBOutlet ToviWebView *webView;
@property ToviAppDelegate *appDelegate;

@property NSString *toOpenFile;
@property NSArray *toOpenFiles;
@end


