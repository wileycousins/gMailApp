//
//  MyWindow.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/13/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "MyWindow.h"
#import "AppDelegate.h"

@implementation MyWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
  
  if (self){
    // set delegate
    [self setDelegate: self];
  }
  return self;
}

// ctrl + shift + tab
-(void)selectPreviousKeyView:(id)sender{
  NSTabView *view = self.contentView;
  if(view != nil) {
    NSInteger index = [view indexOfTabViewItem:view.selectedTabViewItem] +1;
    if (index == 1)
      [view selectLastTabViewItem:sender];
    else
      [view selectPreviousTabViewItem:sender];
  }
}

// ctrl + tab
-(void)selectNextKeyView:(id)sender {
  NSTabView *view = self.contentView;
  if(view != nil) {
    NSInteger index = [view indexOfTabViewItem:view.selectedTabViewItem] +1;
    if (index == [[view tabViewItems] count])
      [view selectFirstTabViewItem:sender];
    else
      [view selectNextTabViewItem:sender];
  }
}

// make sure we can handle events properly
- (BOOL)acceptsFirstResponder
{
  return YES;
}

@end
