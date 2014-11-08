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
@property (nonatomic, strong) UILabel *locationButton;
@property (nonatomic, strong) UILabel *interestButton;

- (void)setLocationSelected;
- (void)setInterestSelected;
@end

@protocol FTInviteTableHeaderViewDelegate <NSObject>
@optional

- (void) inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
          didTapLocationButton:(UIButton *)button;

- (void) inviteTableHeaderView:(FTInviteTableHeaderView *)inviteTableHeaderView
          didTapInterestButton:(UIButton *)button;

@end