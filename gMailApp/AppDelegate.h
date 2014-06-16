//
//  AppDelegate.h
//  gMailApp
//
//  Created by H. Cole Wiley on 6/12/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyWindow.h"
#import "MyWebView.h"
#import "MyTabView.h"
#import "Preferences.h"

@class MyWindow;
@class Preferences;
@class MyWebView;
@class MyTabView;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet MyWindow *window;
@property (assign) IBOutlet Preferences *preferences;
@property (weak) IBOutlet NSView *mainView;
@property (weak) IBOutlet MyWebView *loaderView;
@property (weak) IBOutlet MyTabView *tabView;

@end
