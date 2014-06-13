//
//  AppDelegate.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/12/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize mainView;
@synthesize loaderView;
@synthesize tabView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // make tabView be full size
  [window setContentView:tabView];
  [tabView setDelegate:self];
  
  // load gmail
  NSString *urlAddress = @"http://mail.google.com/";
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  
  [self addNewTab:requestObj];
  
  [loaderView setPolicyDelegate:self];
  [loaderView setResourceLoadDelegate:self];
  
  [window setInitialFirstResponder:tabView];
}

- (WebView*)addNewTab:(NSURLRequest *)request {
  
  NSInteger index = [[tabView tabViewItems] count];
  NSString *tabName = [NSString stringWithFormat:@"tab%ld",(long)index];
  NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:tabName ];
  WebView *newWebView = [[WebView alloc] init];
  [newWebView setUIDelegate:self];
  [newWebView setPolicyDelegate:self];
  [newWebView setFrameLoadDelegate:self];
  [item setView: newWebView];
  [item setLabel:tabName];
  [tabView addTabViewItem:item];
  [tabView selectTabViewItemAtIndex: index];
  
  [[newWebView mainFrame] loadRequest:request];
  
  return newWebView;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
  NSString *host = [[request URL] host];
  if ( sender == loaderView && host != nil && [host rangeOfString:@"accounts.google"].location == NSNotFound && [host rangeOfString:@"mail.google"].location == NSNotFound && [host rangeOfString:@"clients6.google"].location == NSNotFound) {
    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
  } else {
    [listener use];
  }
}
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
//  [[sender mainFrame] loadRequest: request];
  NSString *host = [[request URL] host];
  if ([host rangeOfString:@"mail.google.com"].location != NSNotFound || [host rangeOfString:@"accounts.google.com"].location != NSNotFound ) {
    NSLog(@"sign in to new account");
    [self addNewTab:request];
    [listener use ];
  } else {
    [[loaderView mainFrame] loadRequest:request];
  }
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
  [[loaderView mainFrame] loadRequest:request];
  return loaderView;
}

NSInteger unread = 0;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
  for( NSTabViewItem *item in [tabView tabViewItems] ){
    if (frame == [[item view] mainFrame]) {
      [item setLabel:title];
//      NSLog(@"Title: %@", title);
      if( [title rangeOfString:@"("].location != NSNotFound ){
        NSInteger start = [title rangeOfString:@"("].location+1;
        NSInteger end = [title rangeOfString:@")"].location;
        NSString *uString = [title substringWithRange:NSMakeRange(start,end-start)];
//        if ( [uString integerValue] > unread)
        unread = [uString integerValue];
      } else {
        unread = 0;
      }
      
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"%ld",(long)unread]];
      if ( unread == 0 ) {
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
      }
    }

  }
}
- (IBAction)addNewAccount:(id)sender {
  // load gmail
  NSInteger index = [[tabView tabViewItems] count];
  NSString *urlAddress = [NSString stringWithFormat:@"https://mail.google.com/mail/u/%ld",(long)index];
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  
  [self addNewTab:requestObj];
}

- (IBAction)closeTab:(id)sender {
  [tabView removeTabViewItem:[tabView selectedTabViewItem]];
}

@end
