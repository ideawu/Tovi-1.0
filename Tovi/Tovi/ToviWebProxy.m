//
//  ToviWebProxy.m
//  Tovi
//
//  Created by ideawu on 13-3-31.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviWebProxy.h"
#import "ToviWebView.h"
#import "ToviWindowController.h"
#import "File.h"
#import "JSON.h"
#import "HTML.h"

@implementation ToviWebProxy

@synthesize webView = webView;

- (void)clear{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	[script evaluateWebScript:@"tovi.clear();"];
}

- (void)seek:(NSUInteger)index{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"tovi.seek(%lu)", (unsigned long)index];
	[script evaluateWebScript:codes];
}

- (void)seek:(NSUInteger)index animation:(BOOL)yesno{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"tovi.seek(%lu, %d)", (unsigned long)index, (int)yesno];
	[script evaluateWebScript:codes];
}

- (NSString *)currentFile{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"tovi.cells[tovi.index].url"];
	id res = [script evaluateWebScript:codes];
	if([res isKindOfClass:[WebUndefined class]]){
		return nil;
	}
	NSString *file = [res description];
	// see openfiles: we have encoded the file path, so now decode it
	file = urldecode(file);
	return file;
}

- (void)openfile:(NSString *)filename scandir:(BOOL)scandir{
	NSArray *files;
	if(scandir){
		NSString *dir;
		if([File isdir:filename]){
			dir = filename;
		}else{
			dir = [File dirname:filename];
		}

		files = [File scandir:dir fullpath:YES];
		if(!files || [files count] == 0){
			// in case sandbox denied
			files = [NSArray arrayWithObject:filename];
		}
	}else{
		files = [NSArray arrayWithObject:filename];
	}
	[self openfiles:files seekToFile:filename];
}

- (void)openfiles:(NSArray *)files{
	NSMutableArray *filenames = [NSMutableArray array];
	for(NSString *file in files){
		NSArray *arr;
		if([File isdir:file]){
			arr = [File scandir:file fullpath:YES];
		}else{
			arr = [NSArray arrayWithObject:file];
		}
		[filenames addObjectsFromArray:arr];
	}
	[self openfiles:filenames seekToFile:nil];
}

- (void)openfiles:(NSArray *)files seekToFile:(NSString *)theFile{
	NSLog(@"total %lu file(s)", [files count]);
	NSMutableArray *imgs = [NSMutableArray array];
	for(NSString *file in files){
		NSString *ext = [File extension:file];
		CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, nil);
		if(UTTypeConformsTo(uti, kUTTypeImage)){
			[imgs addObject:file];
		}
	}

	NSLog(@"show %lu file(s)", [imgs count]);

	NSMutableString *codes = [NSMutableString stringWithCapacity:8196];
	WebScriptObject *script = [[webView mainFrame] windowObject];
	for(NSString *file in imgs){
		// Webkit will try to decode the url, so if it contains specialchars like '%'
		// it won't work.
		NSString *f = urlencode(file);
		[codes appendFormat:@"tovi.add('<img tovi_src=\"%@\"/>');", f];
	}
	//NSLog(@"a");
	//NSLog(@"%@", codes);
	[self clear];
	[script evaluateWebScript:codes];
	//NSLog(@"b");

	NSUInteger index = [imgs indexOfObject:theFile];
	if(index != NSNotFound){
		[self seek:index animation:NO];
		NSLog(@"seek %lu %@", (unsigned long)index, theFile);
	}else{
		[self seek:0 animation:NO];
		//NSLog(@"%@ not found", theFile);
	}

	NSLog(@"done");
}

- (void)sendKeyDown: (int)code{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"fake_keyboard_event({which: %d})", code];
	NSLog(@"%@", codes);
	[script evaluateWebScript:codes];
}

- (void)reloadFiles{
	ToviWindowController *controller = self.webView.window.windowController;
	if(controller.toOpenFile){
		[self openfile:controller.toOpenFile scandir:YES];
	}else if(controller.toOpenFiles){
		[self openfiles:controller.toOpenFiles];
	}
}

- (void)changeTheme:(NSString *)themeName{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"change_theme('%@')", themeName];
	NSLog(@"%@", codes);
	[script evaluateWebScript:codes];
}

// javascript do not get a resize event until the NSWindow resize animation is finished.
// so this method is called when NSWindow is resizing
- (void)webViewResize:(NSSize)size{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"autosize()"];
	//NSLog(@"%@", codes);
	[script evaluateWebScript:codes];
}

- (void)rotate:(int)degree{
	WebScriptObject *script = [[webView mainFrame] windowObject];
	NSString *codes = [NSString stringWithFormat:@"tovi.rotate(%d)", degree];
	NSLog(@"%@", codes);
	[script evaluateWebScript:codes];
}

@end
