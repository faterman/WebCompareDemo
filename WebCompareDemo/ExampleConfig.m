//
//  ExampleConfig.m
//  WebCompareDemo
//
//  Created by 薛晓雨 on 2019/1/4.
//  Copyright © 2019 faterman. All rights reserved.
//

#import "ExampleConfig.h"
#import "WebViewJavascriptBridge.h"
@interface ExampleConfig () <WKNavigationDelegate> {}
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;

@end

@implementation ExampleConfig
+ (instancetype)shared {
    static ExampleConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [ExampleConfig new];
    });
    return config;
}

- (void)preLoadWebView {
    
    if (self.webview) {
        return;
    }
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.webview.navigationDelegate = self;
    
    
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *basePath = [NSString stringWithFormat: @"%@/www", bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath: basePath isDirectory: YES];
    NSString *indexPath = [NSString stringWithFormat: @"%@/html/ExampleApp.html", basePath];
    NSString *indexContent = [NSString stringWithContentsOfFile:
                              indexPath encoding: NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString: indexContent baseURL: baseUrl];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}


@end
