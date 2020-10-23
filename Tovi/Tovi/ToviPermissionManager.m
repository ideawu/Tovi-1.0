//
//  ToviPermissionManager.m
//  Tovi
//
//  Created by ideawu on 13-4-20.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviPermissionManager.h"

static NSMutableDictionary *urls = nil;

@implementation ToviPermissionManager

+ (NSDictionary *)urls{
	return urls;
}

+ (void)loadUrls{
	urls = [NSMutableDictionary dictionary];

	NSArray *old = [[NSUserDefaults standardUserDefaults] objectForKey:@"permission"];
	if(old != nil){
		for(NSData *data in old){
			NSError *error = nil;
			NSURL *url = [NSURL URLByResolvingBookmarkData:data
												   options:NSURLBookmarkResolutionWithSecurityScope
											 relativeToURL:nil bookmarkDataIsStale:nil error:&error];
			[urls setObject:url forKey:[url path]];
			//NSLog(@"restore saved permission: %@", [url path]);
		}
	}
}

+ (void)saveUrls{
	//NSLog(@"urls to save: %@", urls);
	NSMutableArray *bookmarks = [NSMutableArray array];
	for(NSURL *url in [urls allValues]){
		NSError *error = nil;
		NSData *data = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
					 includingResourceValuesForKeys:nil
									  relativeToURL:nil
											  error:&error];
		if (error) {
			NSLog(@"Error creating bookmark for URL (%@): %@", url, error);
			[NSApp presentError:error];
		} else {
			[bookmarks addObject:data];
		}
	}
	[[NSUserDefaults standardUserDefaults] setObject:bookmarks forKey:@"permission"];
}

+ (void)accquireAll{
	if(urls != nil){
		[self releaseAll];
	}
	[self loadUrls];
	for(NSURL *url in [urls allValues]){
		BOOL ok = [url startAccessingSecurityScopedResource];
		if(!ok){
			NSLog(@"Accessed: %d %@", ok, [url relativePath]);
		}
	}
	//NSLog(@"startAccess: %@", [urls allKeys]);
}

+ (void)releaseAll{
	for(NSURL *url in [urls allValues]){
		[url stopAccessingSecurityScopedResource];
	}
	//NSLog(@"stopAccess: %@", [urls allKeys]);
	urls = nil;
}

+ (void)addPath:(NSString *)path{
	if([urls objectForKey:path] != nil){
		return;
	}
	NSLog(@"add permission for path: %@", path);
	
	NSURL *url = [NSURL fileURLWithPath:path];
	[url startAccessingSecurityScopedResource];
	
	[urls setObject:url forKey:[url path]];
	[self saveUrls];
}

+ (void)removePath:(NSString *)path{
	NSURL *url = [urls objectForKey:path];
	if(url == nil){
		return;
	}
	[url stopAccessingSecurityScopedResource];
	NSLog(@"stopAccess: %@", [url path]);

	[urls removeObjectForKey:path];
	[self saveUrls];
}

@end
