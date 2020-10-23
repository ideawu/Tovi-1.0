//
//  ToviPreferenceController.h
//  Tovi
//
//  Created by ideawu on 13-4-14.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ToviAppDelegate;

@interface ToviPreferenceController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>{
	NSMutableArray *themeNames;
	NSArray *permissionPaths;
}

@property ToviAppDelegate *appDelegate;

@property (weak) IBOutlet NSTableView *themesView;
@property (weak) IBOutlet NSTableView *permissionsView;

+ (NSString *) prefThemeName;
+ (void) setPrefThemeName:(NSString *)themeName;

+ (BOOL)permissionAlertPopped;
+ (void)setPermissionAlertPopped:(BOOL)yesno;

@property (strong) IBOutlet NSViewController *popoverController;
@property (strong) IBOutlet NSPopover *popover;

@property BOOL modal;

@end
