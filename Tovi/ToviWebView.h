//
//  ToviWebView.h
//  Tovi
//
//  Created by ideawu on 13-3-31.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <WebKit/WebKit.h>

@class ToviAppDelegate;
@class ToviWebProxy;
@class ToviWebExternal;
@class ToviWebDelegate;

@interface ToviWebView : WebView{
	
}
@property ToviAppDelegate *appDelegate;

@property (readonly) ToviWebProxy *toviProxy;
@property (readonly) ToviWebExternal *toviExternal;
@property (readonly) ToviWebDelegate *toviDelegate;

@end
