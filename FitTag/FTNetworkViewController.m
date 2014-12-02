//
//  FTNetworkViewControler.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

/*
#import "FTNetworkViewController.h"
#import "Reachability.h"

#define REFRESH_BUTTON_WIDTH 32
#define REFRESH_BUTTON_HEIGHT 32
#define REFRESH_BUTTON_X(w,w1) (w - w1) / 2
#define REFRESH_BUTTON_Y(h,h1) (h - h1) / 2

@interface FTNetworkViewController()
@property (nonatomic) BOOL isNetworkViewVisible;
@end

@implementation FTNetworkViewController
@synthesize isNetworkViewVisible;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isNetworkViewVisible = NO;
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    [self.view setBackgroundColor:FT_RED];
    
    UIButton *refreshNetworkStatus = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshNetworkStatus setImage:[UIImage imageNamed:REFRESH_NAVIGATION_ITEM] forState:UIControlStateNormal];
    [refreshNetworkStatus addTarget:self action:@selector(didTapRefreshNetworkStatusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [refreshNetworkStatus setFrame:CGRectMake(REFRESH_BUTTON_X(self.view.frame.size.width, REFRESH_BUTTON_WIDTH),
                                              REFRESH_BUTTON_Y(self.view.frame.size.height, REFRESH_BUTTON_HEIGHT),
                                              REFRESH_BUTTON_WIDTH, REFRESH_BUTTON_HEIGHT)];
    [self.view addSubview:refreshNetworkStatus];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isNetworkViewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isNetworkViewVisible = NO;
}

- (void)didTapRefreshNetworkStatusButtonAction:(UIButton *)button {
    [self isNetworkStatusConnected];
}

- (BOOL)isNetworkStatusConnected {
    switch ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        case NotReachable: {
            [FTUtility showHudMessage:@"The internet is down." WithDuration:3];
            return NO;
            
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"The internet is working via WIFI.");
            if (isNetworkViewVisible) {
                [FTUtility showHudMessage:@"Internet is back!" WithDuration:3];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            return YES;
            
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"The internet is working via WWAN.");
            if (isNetworkViewVisible) {
                [FTUtility showHudMessage:@"Internet is back!" WithDuration:3];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            return YES;
            
            break;
        }
    }
    return NO;
}


@end
*/