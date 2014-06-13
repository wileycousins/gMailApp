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
  
  // set delegates
  [tabView setDelegate:self];
  [loaderView setPolicyDelegate:self];
  [loaderView setResourceLoadDelegate:self];
  [window setInitialFirstResponder:tabView];
  [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
  
  // clear old notifications
  [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
  
  //register to listen for event
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(eventHandler:)
   name:@"eventType"
   object:nil ];

  
  // load gmail
  NSString *urlAddress = @"http://mail.google.com/";
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [self addNewTab:requestObj];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if(!window.isVisible) {
        [window makeKeyAndOrderFront:self];
    }
}

//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
  NSLog(@"event triggered");
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
  return YES;
}

- (WebView*)addNewTab:(NSURLRequest *)request {
  
  NSInteger index = [[tabView tabViewItems] count];
  NSString *tabName = [NSString stringWithFormat:@"gMail - %ld",(long)index];
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

- (IBAction)newBrowserWindow:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://google.com"];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [[loaderView mainFrame] loadRequest:requestObj];
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

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
  for( NSTabViewItem *item in [tabView tabViewItems] ){
    if (frame == [(WebView *)[item view] mainFrame]) {
      NSString *tabTitle;
      NSInteger start = [title rangeOfString:@"-"].location+1;
      NSInteger end = [title rangeOfString:@"-" options:NSBackwardsSearch].location;
      tabTitle = [title substringWithRange:NSMakeRange(start,end-start)];
      [item setLabel:tabTitle];
      NSInteger unread = 0;
      if( [title rangeOfString:@"("].location != NSNotFound ){
        start = [title rangeOfString:@"("].location+1;
        end = [title rangeOfString:@")"].location;
        unread = [[title substringWithRange:NSMakeRange(start,end-start)] integerValue];
      } else {
        unread = 0;
      }
      
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"%ld",(long)unread]];
      if ( unread == 0 ) {
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
      } else {
        // set the notification center stuff
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = tabTitle;
        WebView *webView = (WebView *)[[tabView selectedTabViewItem] view];
        NSString *msg = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByClassName('zE')[0].getElementsByTagName('b')[0].innerText"];
        NSLog(@"msg: %@",msg);
        notification.informativeText = msg;
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"eventType"
         object:nil ];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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
