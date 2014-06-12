//
//  AppDelegate.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/12/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize webView;
@synthesize window;
@synthesize loaderView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [window setContentView:webView];
  
  [window setDelegate:self];
  
  [webView setUIDelegate:self];
  [webView setPolicyDelegate:self];
  [webView setResourceLoadDelegate:self];
  [loaderView setPolicyDelegate:self];
  [loaderView setResourceLoadDelegate:self];
  
  NSString *urlAddress = @"http://mail.google.com/";
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [[webView mainFrame] loadRequest:requestObj];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
  NSString *host = [[request URL] host];
  if ([host rangeOfString:@"google"].location == NSNotFound && [host rangeOfString:@"youtube"].location == NSNotFound) {
    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
  } else {
    [listener use];
  }
}
- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
  [[webView mainFrame] loadRequest: request];
  [listener use ];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
  // HACK: This is all a hack to get around a bug/misfeature in Tiger's WebKit
  // (should be fixed in Leopard). On Javascript window.open, Tiger sends a null
  // request here, then sends a loadRequest: to the new WebView, which will
  // include a decidePolicyForNavigation (which is where we'll open our
  // external window). In Leopard, we should be getting the request here from
  // the start, and we should just be able to create a new window.
  
  [[loaderView mainFrame] loadRequest:request];
  return loaderView;
}

@end
