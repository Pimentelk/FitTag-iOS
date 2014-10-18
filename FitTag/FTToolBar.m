//
//  FitTagToolBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTToolBar.h"
#import "FTActivityFeedViewController.h"
#import "FTUserProfileCollectionViewCell.h"
#import "FTSearchViewController.h"
#import "FTRewardsCollectionViewController.h"

@implementation FTToolBar
@synthesize selectedToolBarButton;
@synthesize delegate;

-(void)drawRect:(CGRect)rect {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    // Set toolbar buttons and spaces
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notifications"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didTapNotificationsButtonAction:)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didTapSearchButtonAction:)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"myprofile"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didTapMyProfileButtonAction:)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"offers"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didTapRewardsButtonAction:)]];
    
    // Set the buttons color to red
    [toolbar setTintColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [toolbar setItems:toolbarItems animated:NO];
    [toolbar setTranslucent:NO];    
    [self addSubview:toolbar];
}

- (void)didTapNotificationsButtonAction:(id)sender {
    NSLog(@"didTapNotificationsButtonAction::selectedToolBarButton: %u",selectedToolBarButton);
    
    if (!(selectedToolBarButton & FTToolBarNotifications)) {
        if ([self.delegate respondsToSelector:@selector(didTapNotificationsButton:)]){
            [self.delegate didTapNotificationsButton:sender];
        }
        selectedToolBarButton = FTToolBarNotifications;
    }
}

- (void)didTapSearchButtonAction:(id)sender {
    NSLog(@"didTapSearchButtonAction::selectedToolBarButton: %u",selectedToolBarButton);
    
    if (!(selectedToolBarButton & FTToolBarFeed)) {
        if ([self.delegate respondsToSelector:@selector(didTapSearchButton:)]){
            [self.delegate didTapSearchButton:sender];
        }
        selectedToolBarButton = FTToolBarFeed;
    }
}

- (void)didTapMyProfileButtonAction:(id)sender {
    NSLog(@"didTapMyProfileButtonAction::selectedToolBarButton: %u",selectedToolBarButton);
    
    if (!(selectedToolBarButton & FTToolBarProfile)) {
        if ([self.delegate respondsToSelector:@selector(didTapMyProfileButton:)]){
            [self.delegate didTapMyProfileButton:sender];
        }
        selectedToolBarButton = FTToolBarProfile;
    }
}

- (void)didTapRewardsButtonAction:(id)sender {
    NSLog(@"didTapRewardsButtonAction::selectedToolBarButton: %u",selectedToolBarButton);
    
    if (!(selectedToolBarButton & FTToolBarRewards)) {
        if ([self.delegate respondsToSelector:@selector(didTapRewardsButton:)]){
            [self.delegate didTapRewardsButton:sender];
        }
        selectedToolBarButton = FTToolBarRewards;
    }
}

@end