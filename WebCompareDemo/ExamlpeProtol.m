//
//  ExamlpeProtol.m
//  WebCompareDemo
//
//  Created by 薛晓雨 on 2019/1/4.
//  Copyright © 2019 faterman. All rights reserved.
//

#import "ExamlpeProtol.h"
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kURLProtocolHandledKey @"URLProtocolHandledKey"
static BOOL hasRegister = NO;
@interface ExamlpeProtol ()
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation ExamlpeProtol

+ (void)registerCustomBaseProtocal {
    if (hasRegister)    return;
    // SechemaURLProtocol 自定义类 继承于 NSURLProtocol
    [NSURLProtocol registerClass:[ExamlpeProtol class]];
    NSArray *privateStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"]; //此处代码混淆，防止苹果检查
    NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    Class cls = NSClassFromString(className);
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if (cls && sel) {
        if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)cls performSelector:sel withObject:@"http"]; //拦截http、https
            [(id)cls performSelector:sel withObject:@"https"];
        }
    }
    hasRegister = YES;
}

+ (void)unregisterClass{
    if (hasRegister) {
        [NSURLProtocol unregisterClass:[self class]];
        if (@available(iOS 8.4, *)){//8.4后支持 unregisterSchemeForCustomProtocol 方法,8.3 前暂无处理
            NSArray *privateStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"]; //此处代码混淆，防止苹果检查
            NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
            Class cls = NSClassFromString(className);
            SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
            if (cls && sel) {
                if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [(id)cls performSelector:sel withObject:@"http"]; //拦截http、https
                    [(id)cls performSelector:sel withObject:@"https"];
                }
            }
        }
        
        hasRegister = NO;
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
        [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
            return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kURLProtocolHandledKey inRequest:mutableReqeust];
    NSString *urlStr = mutableReqeust.URL.absoluteString;
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *basePath = [NSString stringWithFormat: @"%@/www", bundlePath];
    NSString *indexPath = [NSString stringWithFormat: @"%@/html/ExampleApp.html", basePath];
    NSString *indexContent = [NSString stringWithContentsOfFile:
                              indexPath encoding: NSUTF8StringEncoding error:nil];
    
    NSData *localData = [indexContent dataUsingEncoding: NSUTF8StringEncoding];
    
    
    //找到本地数据家在本地，否则放行
    if (localData.length != 0) {
        CFStringRef pathExtension = (__bridge_retained CFStringRef)[urlStr pathExtension];
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
        CFRelease(pathExtension);
        
        NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
        if (type != NULL)
            CFRelease(type);
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:super.request.URL
                                                            MIMEType:mimeType
                                               expectedContentLength:-1
                                                    textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:localData];
        [self.client URLProtocolDidFinishLoading:self];
    }else{
        self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
    }
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)stopLoading {
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
