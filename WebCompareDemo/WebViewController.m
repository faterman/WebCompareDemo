//
//  WebViewController.m
//  WebCompareDemo
//
//  Created by 薛晓雨 on 2019/1/4.
//  Copyright © 2019 faterman. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#import "ExampleConfig.h"
@interface WebViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) WKWebView *webview;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([ExampleConfig shared].type == 2) {
        // 预加载webview
        self.webview = [ExampleConfig shared].webview;
        self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.webview];
    }else {
        // 非预加载webview
        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:self.webview];
        self.webview.navigationDelegate = self;
        
        
        [WebViewJavascriptBridge enableLogging];
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
        [_bridge setWebViewDelegate:self];
        
        [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"testObjcCallback called: %@", data);
            responseCallback(@"Response from testObjcCallback");
        }];
        
        [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
        
        [self renderButtons:self.webview];
        
        if ([ExampleConfig shared].type == 0) {
            // 加载本地html
            [self loadLocalExamplePage:self.webview];
        }else {
            // 通过protocol获取离线包
            [self loadProtolExamplePage:self.webview];
        }
    }
    
    
    
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(WKWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadLocalExamplePage:(WKWebView*)webView {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *basePath = [NSString stringWithFormat: @"%@/www", bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath: basePath isDirectory: YES];
    NSString *indexPath = [NSString stringWithFormat: @"%@/html/ExampleApp.html", basePath];
    NSString *indexContent = [NSString stringWithContentsOfFile:
                              indexPath encoding: NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString: indexContent baseURL: baseUrl];
}

- (void)loadProtolExamplePage:(WKWebView*)webView {
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baid.com"]]];
}

@end
