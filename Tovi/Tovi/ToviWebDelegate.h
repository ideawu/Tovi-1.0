//
//  ToviRequestIntercept.h
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ToviWebView;
@class ToviWindowController;

@interface ToviWebDelegate : NSObject{
}

@property (weak) ToviWebView *webView;
@property (weak) ToviWindowController *controller;

@end
