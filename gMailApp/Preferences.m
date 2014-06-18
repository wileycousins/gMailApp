//
//  Prefences.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/16/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

@synthesize allOnOff;
@synthesize soundsOnOff;
@synthesize popupsOnOff;
@synthesize reopenOnOff;
@synthesize tabView;
@synthesize textSize;


- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
  
  if (self){
    // set delegate
    [self setDelegate: self];
  }
  [self setContentView:tabView];
  [tabView setDelegate:self];
  
  // load preferences
  
  return self;
}

-(void)loadPreferences {
  // load preferences
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  if( [settings valueForKey:@"not_all"] != nil )
    [allOnOff setState:[settings boolForKey:@"not_all"]];
  else
    [settings setBool:YES forKey:@"not_all"];
  if( [settings valueForKey:@"not_sounds"] != nil )
    [soundsOnOff setState:[settings boolForKey:@"not_sounds"]];
  else
    [settings setBool:YES forKey:@"not_sounds"];
  if( [settings valueForKey:@"not_popups"] != nil )
    [popupsOnOff setState:[settings boolForKey:@"not_popups"]];
  else
    [settings setBool:YES forKey:@"not_popups"];
  if( [settings valueForKey:@"reopen"] != nil )
    [reopenOnOff setState:[settings boolForKey:@"reopen"]];
  else
    [settings setBool:YES forKey:@"reopen"];
  if( [settings valueForKey:@"text_size"] != nil )
    [textSize setIntegerValue:[settings integerForKey:@"text_size"]];
  else
    [settings setInteger:[textSize intValue] forKey:@"text_size"];
}

- (IBAction)updatePreferences:(id)sender {
  [self updateTextSize:nil];
  [self reopenToggle:nil];
  [self notificationsToggle:nil];
  [self soundToggle:nil];
  [self popupsToggle:nil];
  [self close];
}

- (IBAction)updateTextSize:(id)sender {
  [[NSUserDefaults standardUserDefaults] setInteger:[textSize intValue] forKey:@"text_size"];
}

- (IBAction)reopenToggle:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:[reopenOnOff state] forKey:@"reopen"];
}
- (IBAction)notificationsToggle:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:[allOnOff state] forKey:@"not_all"];
  [soundsOnOff setEnabled:[sender state]];
  [popupsOnOff setEnabled:[sender state]];
}
- (IBAction)soundToggle:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:[soundsOnOff state] forKey:@"not_sounds"];
}
- (IBAction)popupsToggle:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:[popupsOnOff state] forKey:@"not_popups"];
}

// ctrl + shift + tab
-(void)selectPreviousKeyView:(id)sender{
  NSInteger index = [tabView indexOfTabViewItem:tabView.selectedTabViewItem] +1;
  if (index == 1)
    [tabView selectLastTabViewItem:sender];
  else
    [tabView selectPreviousTabViewItem:sender];
}

// ctrl + tab
-(void)selectNextKeyView:(id)sender {
  NSInteger index = [tabView indexOfTabViewItem:tabView.selectedTabViewItem] +1;
  if (index == [[tabView tabViewItems] count])
    [tabView selectFirstTabViewItem:sender];
  else
    [tabView selectNextTabViewItem:sender];
}

- (void)swipeWithEvent:(NSEvent *)event {
  NSLog(@"swipe");
}

// make sure we can handle events properly
- (BOOL)acceptsFirstResponder
{
  return YES;
}


@end
