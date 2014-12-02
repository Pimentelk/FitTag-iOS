//
//  UIView+FTRewardsDetailsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "TTTAttributedLabel.h"

@protocol FTRewardsDetailHeaderViewDelegate;
@interface FTRewardsDetailHeaderView : UIView <TTTAttributedLabelDelegate>

@property (nonatomic,weak) id <FTRewardsDetailHeaderViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame reward:(PFObject *)reward;
@end

@protocol FTRewardsDetailHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the business button is tapped
 @param business the PFUser associated with this button
 */
- (void)rewardsDetailHeaderView:(FTRewardsDetailHeaderView *)rewardsDetailHeaderView didTapBusinessButton:(UIButton *)button business:(PFUser *)business;

@end