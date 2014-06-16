//
//  MyWebView.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/16/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "MyWebView.h"

@implementation MyWebView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      // Initialization code here.
  }
  
  [self setAcceptsTouchEvents:YES];
  
  NSLog(@"inited my webview");
  return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (void)swipeWithEvent:(NSEvent *)event {
  NSLog(@"swipe");
}


@end
