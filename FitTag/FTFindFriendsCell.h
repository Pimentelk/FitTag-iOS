//
//  FTFindFriendsCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@class FTProfileImageView;
@protocol FTFindFriendsCellDelegate;

@interface FTFindFriendsCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id<FTFindFriendsCellDelegate> delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UIButton *followButton;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapFollowButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a FTFindFriendsCell should implement.
 */
@protocol FTFindFriendsCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(FTFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;
- (void)cell:(FTFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser;

@end

