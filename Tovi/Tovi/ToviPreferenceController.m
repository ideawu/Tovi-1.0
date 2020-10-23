//
//  ToviPreferenceController.m
//  Tovi
//
//  Created by ideawu on 13-4-14.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviPreferenceController.h"
#import "File.h"
#import "ToviAppDelegate.h"
#import "ToviWebView.h"
#import "ToviWebProxy.h"
#import "ToviPermissionManager.h"

@class ToviAppDelegate;
@class ToviWindowController;

@implementation ToviPreferenceController

- (id)init{
	self = [super initWithWindowNibName:@"PreferenceWindow"];
	themeNames = [[NSMutableArray alloc] init];
	self.modal = NO;
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[themeNames removeAllObjects];

	NSString* themePath = [[NSBundle mainBundle] pathForResource:@"themes"
														  ofType:@""
													 inDirectory:@"tovi-js"];
	//NSLog(@"scan themes in folder: %@", themePath);
	NSArray *files = [File scandir:themePath fullpath:YES];
	for(NSString *dir in files) {
		if([File isdir:dir]){
			NSString *name = [File basename:dir];
			[themeNames addObject:name];
			//NSLog(@"found theme: %@", name);
		}
	}
	[themeNames removeObject:@"default"];
	[themeNames insertObject:@"default" atIndex:0];

	[self.themesView reloadData];

	NSString *currentTheme = [[self class] prefThemeName];
	NSUInteger selectedIndex = [themeNames indexOfObject:currentTheme];
	if(selectedIndex != NSNotFound){
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedIndex];
		[_themesView selectRowIndexes:indexSet byExtendingSelection:NO];
	}

	[self initPermission];
}

- (void)showWindow:(id)sender{
	[super showWindow:sender];
	if(self.modal){
		[NSApp runModalForWindow:self.window];
	}
}

- (void)windowWillClose:(NSNotification *)notification{
	if(self.modal){
		[NSApp stopModal];
	}
}

- (void)initPermission{
	[ToviPermissionManager accquireAll];
	permissionPaths = [[ToviPermissionManager urls] allKeys];
	permissionPaths = [permissionPaths sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
	
	self.permissionsView.delegate = self;
	self.permissionsView.dataSource = self;
	[self.permissionsView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
	if(tableView == self.themesView){
		return themeNames.count;
	}else if(tableView == self.permissionsView){
		return permissionPaths.count;
	}else{
		return 0;
	}
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	if(tableView == self.themesView){
		return [themeNames objectAtIndex:row];
	}else if(tableView == self.permissionsView){
		return [permissionPaths objectAtIndex:row];
	}else{
		return nil;
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
	if(aNotification.object == self.themesView){
		NSInteger index = [self.themesView selectedRow];
		if(index == -1 || index >= themeNames.count){
			return;
		}
		NSString *theme = [themeNames objectAtIndex:index];

		[[self class] setPrefThemeName:theme];

		for(ToviWindowController *t in self.appDelegate.controllers){
			[t.webView.toviProxy changeTheme:theme];
		}
	}
}

+ (NSString *) prefThemeName{
	NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"theme"];
	if(val == nil){
		val = @"default";
	}
	return val;
}

+ (void) setPrefThemeName:(NSString *)themeName{
	[[NSUserDefaults standardUserDefaults] setObject:themeName forKey:@"theme"];
}

+ (BOOL)permissionAlertPopped{
	NSString *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"permissionAlertPopped"];
	if(val != nil && [val compare:@"yes"] == NSOrderedSame){
		return YES;
	}
	return NO;
}
+ (void)setPermissionAlertPopped:(BOOL)yesno{
	if(yesno == YES){
		[[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"permissionAlertPopped"];
	}else{
		[[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"permissionAlertPopped"];
	}
}


- (IBAction)addPermission:(id)sender {
	NSOpenPanel *panel = [[NSOpenPanel alloc] init];
	[panel setTitle:@"Add permission"];
	[panel setMessage:@"It is recommended that you add HOME directory to the permission list."];
	[panel setPrompt:@"Add"];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
	[panel setAllowsMultipleSelection:YES];
	//[panel setDirectoryURL:[NSURL fileURLWithPath:@"/"]];

	NSInteger result = [panel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		for (NSURL *url in [panel URLs]) {
			[ToviPermissionManager addPath:[url path]];
		}
	}
	[self initPermission];
}

- (IBAction)removePermission:(id)sender {
	NSIndexSet *selected = [self.permissionsView selectedRowIndexes];
	NSUInteger index = [selected firstIndex];
	while (index != NSNotFound){
		[ToviPermissionManager removePath:[permissionPaths objectAtIndex:index]];

		//increment
		index = [selected indexGreaterThanIndex:index];
	}
	[self initPermission];
}

- (IBAction)showHelp:(id)sender {
	NSButton *btn = (NSButton *)sender;
	[self.popover showRelativeToRect:btn.bounds ofView:sender preferredEdge:NSMinYEdge];
}

@end
