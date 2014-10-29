//
//  UITableViewCell+FTInviteTableHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/29/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTInviteTableHeaderViewDelegate;
@interface FTInviteTableHeaderView : UICollectionReusableView

@property (nonatomic, weak) id<FTInviteTableHeaderViewDelegate> delegate;

@end

@protocol FTInviteTableHeaderViewDelegate <NSObject>
@optional

- (void) inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
          didTapLocationButton:(UIButton *)button;

- (void) inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
          didTapInterestButton:(UIButton *)button;

@end