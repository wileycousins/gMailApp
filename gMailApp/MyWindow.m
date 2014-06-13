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
  NSLog(@"initing window");
  
  self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
  
  if (self){
    // set delegates
    [self setDelegate: self];
  }
  return self;
}

-(void)selectPreviousKeyView:(id)sender{
  NSTabView *view = self.contentView;
  NSInteger index = [view indexOfTabViewItem:view.selectedTabViewItem] +1;
  if (index == 1)
    [view selectLastTabViewItem:sender];
  else
    [view selectPreviousTabViewItem:sender];
}

-(void)selectNextKeyView:(id)sender {
  NSTabView *view = self.contentView;
  NSInteger index = [view indexOfTabViewItem:view.selectedTabViewItem] +1;
  if (index == [[view tabViewItems] count])
    [view selectFirstTabViewItem:sender];
  else
    [view selectNextTabViewItem:sender];
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
- (void)keyDown:(NSEvent *)theEvent // canBecomeKeyView
{
  NSString *characters;
  
  // if using performKeyEquivalent: enable below
  // if([[self window] firstResponder] != self) return NO;
  
  // get the pressed key
  characters = [theEvent characters];
  
  if ([characters isEqual:@"\t"]) {
//    [[self window] selectNextKeyView:self];
    
    return;
  } else {
    return;
  }
}

@end
