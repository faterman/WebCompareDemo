//
//  ExampleConfig.h
//  WebCompareDemo
//
//  Created by 薛晓雨 on 2019/1/4.
//  Copyright © 2019 faterman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ExampleConfig : NSURLProtocol
@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, assign) NSInteger type;
+ (instancetype)shared;
- (void)preLoadWebView;
@end

NS_ASSUME_NONNULL_END
