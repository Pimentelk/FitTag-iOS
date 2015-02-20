//
//  FTMainViewConrtollerViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 1/29/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTMainViewController.h"
#import "FTNavigationController.h"
#import "FTInviteFriendsViewController.h"
#import "FTSidePanelViewController.h"
#import "FTActivityFeedViewController.h"
#import "FTPlaceProfileViewController.h"
#import "FTUserProfileViewController.h"

#define SLIDE_TIMING .25
#define LEFT_PANEL_TAG 2
#define CORNER_RADIUS 4

@interface FTMainViewController () <FTSidePanelViewControllerDelegate>

@property (nonatomic, strong) FTNavigationController *centerViewController;
@property (nonatomic, strong) UINavigationController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;

@end

@implementation FTMainViewController

- (id)initWithViewController:(FTNavigationController *)viewController {
    self = [super init];
    
    if (self) {
        self.centerViewController = viewController;
        [self addChildViewController:self.centerViewController];
        [_centerViewController didMoveToParentViewController:self];
        [self.centerViewController.view setFrame:self.view.frame];
        [self.view addSubview:self.centerViewController.view];
        
        self.showingLeftPanel = NO;
    }
    
    return self;
}

#pragma mark

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize rectSize = self.view.frame.size;
    
    _centerViewController.view.frame = CGRectMake(0, 0, rectSize.width, rectSize.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    CGSize rectSize = self.view.frame.size;
    
    _centerViewController.view.frame = CGRectMake(0, 0, rectSize.width, rectSize.height);
    [self resetMainView];
}

#pragma mark

- (UIView *)getSettingsPanel {
    
    FTSidePanelViewController *sidePanelViewController = [[FTSidePanelViewController alloc] init];
    sidePanelViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ sidePanelViewController ] animated:NO];
    
    self.leftPanelViewController = navController;
    [self addChildViewController:_leftPanelViewController];
    [_leftPanelViewController didMoveToParentViewController:self];
    [self.leftPanelViewController.view setFrame:self.view.frame];
    
    [self.view addSubview:self.leftPanelViewController.view];
    [self.view sendSubviewToBack:self.leftPanelViewController.view];
    
    return self.leftPanelViewController.view;
}

- (void)movePanelToOriginalPosition {
    
    CGSize rectSize = self.view.frame.size;
    
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(0, 0, rectSize.width, rectSize.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

- (void)movePanelRight {
    
    UIView *childView = [self getSettingsPanel];
    [self.view sendSubviewToBack:childView];
    
    CGSize rectSize = self.view.frame.size;
    
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(rectSize.width, 0, rectSize.width, rectSize.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.showingLeftPanel = YES;
                         }
                     }];
}

- (void)resetMainView {
    
    // remove left view and reset variables, if needed
    if (_leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        self.showingLeftPanel = NO;
    }
}

#pragma mark - FTNavigationControllerDelegate

- (void)navigationController:(FTNavigationController *)navigationController
            didTapMenuButton:(UIBarButtonItem *)button {
    
    [self movePanelRight];
}

- (void)navigationController:(FTNavigationController *)navigationController
          didTapSearchButton:(UISearchBar *)searchBar
                        type:(NSInteger)type {
    
    if (type == 0) {
        
    } else {
        
    }
}

#pragma mark - FTSidePanelViewControllerDelegate

- (void)sidePanelViewController:(FTSidePanelViewController *)sidePanelViewController
         didTapMenuButtonAction:(UIBarButtonItem *)button {
    
    [self movePanelToOriginalPosition];
}

@end
