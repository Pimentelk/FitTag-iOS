//
//  UIView+FTRewardsDetailsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "TTTAttributedLabel.h"

@protocol FTRewardsDetailsHeaderViewDelegate;
@interface FTRewardsDetailsHeaderView : UIView <TTTAttributedLabelDelegate>

@property (nonatomic,weak) id <FTRewardsDetailsHeaderViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame reward:(PFObject *)reward;
@end

@protocol FTRewardsDetailsHeaderViewDelegate <NSObject>
@optional

@end