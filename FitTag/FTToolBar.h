//
//  FitTagToolBar.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTToolBarNone = 0,
    FTToolBarFeed = 1 << 0,
    FTToolBarRewards = 1 << 1,
    FTToolBarNotifications = 1 << 2,
    FTToolBarProfile = 1 << 3,
    FTToolBarMap = 1 << 4,
    FTToolBarDefault = FTToolBarMap
} FTToolBarButton;


@protocol FTToolBarDelegate <UIToolbarDelegate>
@required
-(void)didTapNotificationsButton:(id)sender;
-(void)didTapSearchButton:(id)sender;
-(void)didTapMyProfileButton:(id)sender;
-(void)didTapRewardsButton:(id)sender;
@end

@interface FTToolBar : UIToolbar
@property (weak, nonatomic) id <FTToolBarDelegate> delegate;
@property (nonatomic, readonly, assign) FTToolBarButton selectedToolBarButton;
@end