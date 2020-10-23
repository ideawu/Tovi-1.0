//
//  ToviWebView.m
//  Tovi
//
//  Created by ideawu on 13-3-31.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviWebView.h"
#import "ToviWebProxy.h"
#import "ToviWebExternal.h"
#import "ToviWindowController.h"
#import "ToviWebDelegate.h"
#import "File.h"
#import "ToviAppDelegate.h"

@implementation ToviWebView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }

	_toviExternal = [[ToviWebExternal alloc] init];
	_toviExternal.webView = self;
	_toviProxy = [[ToviWebProxy alloc] init];
	_toviProxy.webView = self;
	_toviDelegate = [[ToviWebDelegate alloc] init];
	_toviDelegate.webView = self;

	[self setUIDelegate:_toviDelegate];
	[self setFrameLoadDelegate:_toviDelegate];
	[self setResourceLoadDelegate:_toviDelegate];
	[self setPolicyDelegate:_toviDelegate];

	
	NSArray *draggedTypes = [NSArray arrayWithObjects: NSFilenamesPboardType, nil];
	[self registerForDraggedTypes:draggedTypes];
    [[[self mainFrame] frameView] setAllowsScrolling:NO];

    return self;
}

- (void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
	[_toviProxy webViewResize:self.frame.size];
}

- (void)drawRect:(NSRect)dirtyRect
{
   // Drawing code here.
	[super drawRect:dirtyRect];
}

- (void)keyDown:(NSEvent *)theEvent{
	//NSLog(@"toviwebview %@", theEvent);
	[super keyDown:theEvent];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender{
	return YES;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
	return NSDragOperationGeneric;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	//NSLog(@"%@", NSStringFromSelector(_cmd));
    NSPasteboard *pboard = [sender draggingPasteboard];

	ToviWindowController *controller = self.window.windowController;

    if ([[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		if([files count] == 1){
			//[_toviProxy openfile:[files objectAtIndex:0] scandir:YES];
			[self.appDelegate openWindowWithFile:[files objectAtIndex:0] orFilenames:nil];
		}else{
			[_toviProxy openfiles:files];
		}
		controller.toOpenFiles = files;
	}

    return YES;
}

@end
