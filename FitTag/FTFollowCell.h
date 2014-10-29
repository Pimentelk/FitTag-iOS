//
//  UITableViewCell+FTInviteCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTFollowCellDelegate;

@interface FTFollowCell : UITableViewCell

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, weak) id<FTFollowCellDelegate> delegate;

@end

@protocol FTFollowCellDelegate <NSObject>
@optional

- (void) followCell:(FTFollowCell *)inviteCell didTapFollowButton:(UIButton *)button user:(PFUser *)aUser;

- (void) followCell:(FTFollowCell *)inviteCell didTapProfileImage:(UIButton *)button user:(PFUser *)aUser;

@end
