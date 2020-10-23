//
//  ToviAppDelegate.m
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviAppDelegate.h"
#import "ToviPreferenceController.h"
#import "ToviWebView.h"
#import "ToviWebProxy.h"
#import "File.h"
#import "HTML.h"
#import "ToviPermissionManager.h"

@implementation ToviAppDelegate

@synthesize controllers = toviControllers;

- (id)init{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	self = [super init];
	toviControllers = [NSMutableArray array];
	return self;
}

- (void)applicationWillTerminate:(NSNotification *)notification{
	[toviControllers removeAllObjects];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification{
	[ToviPermissionManager accquireAll];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	if([toviControllers count] == 0){
		[self openWindowWithFile:nil orFilenames:nil];
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
	NSLog(@"%@ %@", NSStringFromSelector(_cmd), filename);
	[self openWindowWithFile:filename orFilenames:nil];
	return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames{
	NSLog(@"%@ %@", NSStringFromSelector(_cmd), filenames);
	if([filenames count] == 1){
		[self openWindowWithFile: [filenames objectAtIndex:0] orFilenames:nil];
	}else{
		[self openWindowWithFile:nil orFilenames:filenames];
	}
}

- (IBAction)onNewWindow:(id)sender {
	[self openWindowWithFile:nil orFilenames:nil];
}

- (IBAction)onAbout:(id)sender {
	if(!aboutWindow){
		aboutWindow = [[ToviAboutWindowController alloc] init];
	}
	[aboutWindow showWindow:self];
}

- (ToviWindowController *)currentController{
	ToviWindowController *t;
	for(t in toviControllers){
		if(t.window == [NSApp keyWindow]){
			break;
		}
	}
	return t;
}

- (IBAction)onCopy:(id)sender {
	ToviWindowController *controller = [self currentController];
	if(!controller){
		return;
	}
	NSString *file = [controller.webView.toviProxy currentFile];
	if(!file || file.length == 0){
		return;
	}
	
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	[pboard clearContents];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:file];
	NSArray *arr = [NSArray arrayWithObjects:url, nil];
	[pboard writeObjects:arr];
	NSLog(@"copy %@", file);
}

- (IBAction)onSave:(id)sender {
	ToviWindowController *controller = [self currentController];
	if(!controller){
		return;
	}
	NSString *file = [controller.webView.toviProxy currentFile];
	if(!file || file.length == 0){
		return;
	}
	
	/*

	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setCanCreateDirectories:YES];
	[panel setNameFieldStringValue:[file lastPathComponent]];
	[panel beginSheetModalForWindow:controller.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton){
			NSString *newfile = [[panel URL] path];
			NSImage *img = [[NSImage alloc] initWithContentsOfFile:file];




			float degrees = 90;
			NSSize beforeSize = [img size];
			NSSize newSize = (degrees == 90 || degrees == -90) ? NSMakeSize(beforeSize.height, beforeSize.width) : beforeSize;

			NSImage* rotatedImage = [[NSImage alloc] initWithSize:newSize];

			NSPoint p = NSMakePoint(img.size.height / 2, img.size.width / 2);
			NSAffineTransform *transform = [NSAffineTransform transform];
			[transform translateXBy: p.x yBy: p.y];
			[transform rotateByDegrees:90];
			[transform translateXBy: -p.y yBy: -p.x];

			// draw the original image, rotated, into the new image
			[rotatedImage lockFocus];
			[transform concat];
			NSRect dstRect = {NSMakePoint(img.size.width / 2, img.size.height / 2), newSize};
			NSRect srcRect = {NSZeroPoint, img.size};
			[img drawInRect:dstRect
				   fromRect:srcRect
				  operation:NSCompositeCopy
				   fraction:1.0];
			[rotatedImage unlockFocus];

			NSBitmapImageRep *rep = [[rotatedImage representations] objectAtIndex:0];
			NSData *data = [rotatedImage TIFFRepresentation];
			//NSData *data = [rep representationUsingType:NSJPEGFileType properties:nil];
			[data writeToFile:newfile atomically:NO];
			
			NSLog(@"%@ => %@", file, newfile);
        }
    }];
	 */
}

- (IBAction)onShowInFinder:(id)sender {
	ToviWindowController *controller = [self currentController];
	if(!controller){
		return;
	}
	NSString *file = [controller.webView.toviProxy currentFile];
	if(!file || file.length == 0){
		return;
	}

	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws selectFile:file inFileViewerRootedAtPath:nil];
}

- (IBAction)onOpenFile:(id)sender {
	NSMutableArray *fileTypes = [NSMutableArray arrayWithArray:[NSImage imageFileTypes]];
	[fileTypes addObject:@"svg"];
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setMessage:@"Select files and/or directories."];
	[panel setAllowsMultipleSelection:YES];
	[panel setCanChooseDirectories:YES];
	[panel setAllowedFileTypes:fileTypes];

	/*
	NSButton *button = [[NSButton alloc] init];
	[button setButtonType:NSSwitchButton];
	button.title = NSLocalizedString(@"Only selected file", @"");
	[button sizeToFit];
	[panel setAccessoryView:button];
	 */

	NSInteger i = [panel runModal];
	if(i == NSOKButton){
		if(panel.URLs.count == 1){
			NSURL *url = [[panel URLs] objectAtIndex:0];
			NSString *filename = url.path;
			[self openWindowWithFile:filename orFilenames:nil];
		}else{
			NSMutableArray *filenames = [NSMutableArray array];
			for(NSURL *url in [panel URLs]){
				[filenames addObject:[url path]];
				//NSLog(@"%@", [url path]);
			}
			[self openWindowWithFile:nil orFilenames:filenames];
		}
    }
}

- (void)openWindowWithFile:(NSString *)filename orFilenames:(NSArray *)filenames{
	if(filename){
		NSString *dir = [File dirname:filename];
		if(!access([dir UTF8String], R_OK) == 0){
			if([ToviPreferenceController permissionAlertPopped] == NO){
				NSString *msg = [NSString stringWithFormat:@"You have to add directory '%@' to Permissions list in Preferences window!\n\nOr Tovi will not be able to scan image files in the same direcotry.", dir];
				NSAlert *alert = [[NSAlert alloc] init];
				[alert setMessageText:@"Permission denied!"];
				[alert setInformativeText:msg];
				[alert runModal];

				[self onPreferences: nil];

				[ToviPreferenceController setPermissionAlertPopped:YES];
			}
		}
	}

	ToviWindowController *t;
	for(t in toviControllers){
		if(!t.toOpenFile && !t.toOpenFiles){
			t.toOpenFile = filename;
			t.toOpenFiles = filenames;
			[t showWindow:self];
			[t.webView.toviProxy reloadFiles];
			return;
		}
	}
	
	t = [[ToviWindowController alloc] init];
	[toviControllers addObject:t];
	t.appDelegate = self;
	t.toOpenFile = filename;
	t.toOpenFiles = filenames;
	[t showWindow:self];

}

- (IBAction)onMenuClick:(id)sender {
	ToviWindowController *controller = [self currentController];

	NSMenuItem *item = sender;
	if([item.title caseInsensitiveCompare:@"Previous"] == NSOrderedSame){
		[controller.webView.toviProxy sendKeyDown:37];
	}else if([item.title caseInsensitiveCompare:@"Next"] == NSOrderedSame){
		[controller.webView.toviProxy sendKeyDown:39];
	}else if([item.title caseInsensitiveCompare:@"Zoom In"] == NSOrderedSame){
		[controller.webView.toviProxy sendKeyDown:38];
	}else if([item.title caseInsensitiveCompare:@"Zoom Out"] == NSOrderedSame){
		[controller.webView.toviProxy sendKeyDown:40];
	}else if([item.title caseInsensitiveCompare:@"Rotate Left"] == NSOrderedSame){
		[controller.webView.toviProxy rotate:-90];
	}else if([item.title caseInsensitiveCompare:@"Rotate Right"] == NSOrderedSame){
		[controller.webView.toviProxy rotate:+90];
	}else if(item == [self slideShowMenuItem]){
		[controller.webView.toviProxy sendKeyDown:13];
	}else{
	}
}

- (IBAction)onPreferences:(id)sender {
	preferenceWindow = [[ToviPreferenceController alloc] init];
	[preferenceWindow setAppDelegate:self];
	if(!sender){
		[preferenceWindow setModal:YES];
	}
	[preferenceWindow showWindow:self];
}

@end
