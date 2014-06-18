//
//  Prefences.h
//  gMailApp
//
//  Created by H. Cole Wiley on 6/16/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import <Cocoa/Cocoa.h>

BOOL notificationAll;
BOOL notificationSounds;
BOOL notificationPopups;
BOOL reopenTabs;

@interface Preferences : NSWindow <NSWindowDelegate, NSTabViewDelegate>

// notification prefeneces
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSButton *allOnOff;
@property (weak) IBOutlet NSButton *soundsOnOff;
@property (weak) IBOutlet NSButton *popupsOnOff;

@property (weak) IBOutlet NSButton *reopenOnOff;
@property (weak) IBOutlet NSTextField *textSize;

-(void)loadPreferences;

@end
