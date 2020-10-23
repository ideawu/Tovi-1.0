//
//  ToviRequestIntercept.m
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "ToviWebView.h"
#import "ToviWebDelegate.h"
#import "ToviWindowController.h"
#import "File.h"

@implementation ToviWebDelegate

@synthesize webView = webView;

- (id)init{
	self = [super init];
	return self;
}

- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)script{
	//NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
	[script setValue:self.webView.toviExternal forKey:@"external"];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame{
	[self.webView.window setTitle:title];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMenuItem *copy = [[NSMenuItem alloc] initWithTitle:@"Copy"
												  action:@selector(onCopy:)
										   keyEquivalent:[NSString stringWithFormat:@"%c%c", NSCommandKeyMask, 'c', nil]];
	NSMenuItem *show = [[NSMenuItem alloc] initWithTitle:@"Show in Finder"
												  action:@selector(onShowInFinder:)
										   keyEquivalent:@""];
	[copy setTarget:self.controller.appDelegate];
	[show setTarget:self.controller.appDelegate];
	
	NSMutableArray *ret = [NSMutableArray array];
	[ret addObject:copy];
	[ret addObject:show];
	return ret;
}

- (void)webView:(WebView *)webView
		decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request frame:(WebFrame *)frame
		decisionListener:(id < WebPolicyDecisionListener >)listener{
    NSString *host = [[request URL] host];
    if (host) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    } else {
        [listener use];
    }
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource{
	//NSLog(@"%@ %@", NSStringFromSelector(_cmd), request);
	if(request.URL.isFileURL){
		NSLog(@"resource: %@", [File basename: request.URL.absoluteString]);
	}else{
		NSLog(@"resource: %@", request.URL);
	}
	request = [NSURLRequest requestWithURL:[request URL]
							   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
						   timeoutInterval:[request timeoutInterval]];
	return request;
}


/*
init:
	[NSURLProtocol registerClass:[MyProtocol class]];
WebResourceLoadDelegate:
	willSendRequest(): perhaps
MyProtocol
	canInitWithRequest: return YES
	startLoading: generate response
		[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
		[self.client URLProtocol:self didLoadData:data];
		[self.client URLProtocolDidFinishLoading:self];
 // TODO: scale image without antialias
*/

@end
