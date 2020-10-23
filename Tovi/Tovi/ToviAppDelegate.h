//
//  ToviAppDelegate.h
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToviWindowController.h"
#import "ToviAboutWindowController.h"

@class ToviPreferenceController;

@interface ToviAppDelegate : NSObject <NSApplicationDelegate>{
	NSMutableArray *toviControllers;
	ToviAboutWindowController *aboutWindow;
	ToviPreferenceController *preferenceWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenuItem *slideShowMenuItem;
@property (readonly) NSMutableArray *controllers;

- (IBAction)onMenuClick:(id)sender;
- (IBAction)onNewWindow:(id)sender;
- (IBAction)onAbout:(id)sender;
- (IBAction)onCopy:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)onShowInFinder:(id)sender;
- (IBAction)onPreferences:(id)sender;

- (void)openWindowWithFile:(NSString *)filename orFilenames:(NSArray *)filenames;

@end
