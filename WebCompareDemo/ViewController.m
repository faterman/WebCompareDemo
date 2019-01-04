//
//  ViewController.m
//  WebCompareDemo
//
//  Created by 薛晓雨 on 2019/1/4.
//  Copyright © 2019 faterman. All rights reserved.
//

#import "ViewController.h"
#import "ExampleConfig.h"
@interface ViewController () {
    NSInteger _selectIndex;
}
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _selectIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)methodChanged:(UISegmentedControl *)sender {
    [ExampleConfig shared].type = sender.selectedSegmentIndex;
    if ([ExampleConfig shared].type == 2) {
        [[ExampleConfig shared] preLoadWebView];
    }
}

@end
