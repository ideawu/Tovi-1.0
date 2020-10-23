//
//  ToviWindowController.m
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviWindowController.h"
#import "ToviWebView.h"
#import "File.h"
#import "ToviAppDelegate.h"
#import "tovi.h"

@implementation ToviWindowController

@synthesize toOpenFile = toOpenFile;
@synthesize toOpenFiles = toOpenFiles;
@synthesize appDelegate = appDelegate;

- (id)init{
	self = [super initWithWindowNibName:@"ToviWindow"];
	return self;
}

- (void)dealloc{
	//NSLog(@"controller dealloc");
}

- (id)initWithWindow:(NSWindow *)window{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowWillClose:(NSNotification *)notification{
	[appDelegate.controllers removeObject:self];
}

- (void)windowDidLoad{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
    [super windowDidLoad];
	self.webView.appDelegate = appDelegate;

	//self.window.delegate = self;

	// load html file
	/*
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"tovi"
														 ofType:@"html"
													inDirectory:@"tovi-js"];
	NSLog(@"WebView load %@", filePath);
	NSURL* fileURL = [NSURL fileURLWithPath:filePath];
	NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
	[[self.webView mainFrame] loadRequest:request];
	 */

	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"tovi-js"
														 ofType:@""
													inDirectory:@""];
	NSLog(@"WebView load %@", filePath);
	NSURL* fileURL = [NSURL fileURLWithPath:filePath];
	//NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];

	[self.webView .mainFrame loadHTMLString:tovi_html baseURL:fileURL];
}

- (void)keyDown:(NSEvent *)theEvent{
	//NSLog(@"%@ %@", theEvent.characters, theEvent);
	if([theEvent.characters caseInsensitiveCompare:@"f"] == NSOrderedSame){
		return [self.window zoom: nil];
	}else if([theEvent.characters caseInsensitiveCompare:@"q"] == NSOrderedSame){
		if((self.window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask){
			NSLog(@"exit fullscreen");
			[self.window toggleFullScreen:self];
		}else{
			[self.window performClose:self];
		}
	}else if(theEvent.keyCode == 53){
		if((self.window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask){
			NSLog(@"exit fullscreen");
			[self.window toggleFullScreen:self];
		}else{
			[self.window performClose:self];
		}
	}else{
	}
	//[NSMenu setMenuBarVisible:NO];
	/*
	 [self.window
	 setFrame:[self.window frameRectForContentRect:[[self.window screen] frame]]
	 display:YES
	 animate:NO];
	 */
}

@end


