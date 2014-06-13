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
  
  // load user defaults
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSArray *tabs = [settings valueForKey:@"tabs"];
  
  // if there are saved tabs, load them
  if (tabs != nil && tabs.count > 0) {
    for( NSString *urlAddress in tabs){
      NSURL *url = [NSURL URLWithString:urlAddress];
      NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
      [self addNewTab:requestObj];
    }
    [tabView selectTabViewItemAtIndex:0];
  } else {
    // load gmail
    NSString *urlAddress = @"http://mail.google.com/";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self addNewTab:requestObj];
  }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // save open windwos to user defaults
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSMutableArray *tabs = [[NSMutableArray alloc] init];
  for( NSTabViewItem *item in [tabView tabViewItems] ){
    WebView *webView = [item view];
    NSString *url = [[[[[webView mainFrame] dataSource] request] URL] absoluteString];
    if (url != nil)
      [tabs addObject:url];
  }
  [settings setValue:[NSArray arrayWithArray:tabs] forKey:@"tabs"];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if(!window.isVisible) {
        [window makeKeyAndOrderFront:self];
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
  for( NSTabViewItem *item in [tabView tabViewItems] ){
    if ([item.label isEqualToString:[notification title]]){
      [tabView selectTabViewItem:item];
      WebView *webView = [item view];
      if (webView != nil) {
        [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByClassName('zE')[0].click();"];
      }
    }
  }
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

// updated title on a webview
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
  // iterate through the tabs
  for( NSTabViewItem *tabItem in [tabView tabViewItems] ){
    // is this the right tab? does this title have the email in it?
    if (frame == [[tabItem view] mainFrame] && [title rangeOfString:@"@"].location != NSNotFound) {
      NSString *tabTitle;
      NSInteger start = [title rangeOfString:@"- "].location+2;
      NSInteger end = [title rangeOfString:@" -" options:NSBackwardsSearch].location;
      tabTitle = [title substringWithRange:NSMakeRange(start,end-start)];
      [tabItem setLabel:tabTitle];
      NSInteger unread = 0;
      
      // check if there are unread messages
      if( [title rangeOfString:@"("].location != NSNotFound ){
        start = [title rangeOfString:@"("].location+1;
        end = [title rangeOfString:@")"].location;
        unread = [[title substringWithRange:NSMakeRange(start,end-start)] integerValue];
      } else {
        unread = 0;
      }
      
      // updat the badge count
      [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"%ld",(long)unread]];
      
      if ( unread == 0 ) {
        // hide the badge count
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
        
        // check if there are any notifications in the center that need to be dismissed, since there is no mail
        for ( NSUserNotification *notification in [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications] ) {
          if ([tabItem.label isEqualToString:[notification title]]){
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
          }
        }
      } else {
        // set the notification center message
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = tabTitle;
        WebView *webView = [[tabView selectedTabViewItem] view];
        if (webView != nil) {
          NSString *msg = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByClassName('zE')[0].getElementsByTagName('b')[0].innerText"];
          notification.informativeText = msg;
        }
        notification.soundName = NSUserNotificationDefaultSoundName;
        
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


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
  return YES;
}

@end
