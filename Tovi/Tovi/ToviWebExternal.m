//
//  ToviWebkitExternal.m
//  Tovi
//
//  Created by ideawu on 13-3-31.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviWebView.h"
#import "ToviWebExternal.h"
#import "ToviWebProxy.h"
#import "ToviWindowController.h"
#import "ToviPreferenceController.h"

@implementation ToviWebExternal

@synthesize webView = webView;


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name{
	//NSLog(@"%@ received %@ for '%s'", self, NSStringFromSelector(_cmd), name);
	return YES;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
	//NSLog(@"%@ received %@ for '%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(selector));
	static NSSet *methods = nil;
	if(methods == nil){
		methods = [NSSet setWithObjects:
				   NSStringFromSelector(@selector(log:)),
				   @"documentReady",
				   nil];
	}
    if([methods containsObject:NSStringFromSelector(selector)]){
	   return NO;
    }
    return YES;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel {
	//NSLog(@"%@ received %@ with sel='%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(sel));
	static NSDictionary *names = nil;
	if(names == nil) {
		names = [NSDictionary dictionaryWithObjectsAndKeys:
				 @"log", NSStringFromSelector(@selector(log:)),
				 @"documentReady", @"documentReady",
				 nil];
	}
	NSString *name = [names objectForKey: NSStringFromSelector(sel)];
	return name;
}

// Invoked by javascript when document ready
- (void)documentReady{
	ToviWindowController *controller = self.webView.window.windowController;
	
	NSLog(@"%@", NSStringFromSelector(_cmd));
	if(controller.toOpenFile){
		[self.webView.toviProxy openfile:controller.toOpenFile scandir:YES];
	}else if(controller.toOpenFiles){
		[self.webView.toviProxy openfiles:controller.toOpenFiles];
	}
	
	NSString *theme = [ToviPreferenceController prefThemeName];
	//NSLog(@"use theme: %@", theme);
	[self.webView.toviProxy changeTheme:theme];
}

- (void)log:(NSString *)msg{
	NSLog(@"log by js: %@", msg);
}

@end
