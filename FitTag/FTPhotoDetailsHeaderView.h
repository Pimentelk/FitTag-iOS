//
//  FTPhotoDetailsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@class PFImageView;
@protocol FTPhotoDetailsHeaderViewDelegate;
@interface FTPhotoDetailsHeaderView : UIView


/*! @name Managing View Properties */

/// The displayname button
@property (nonatomic, strong) UIButton *usernameRibbon;

/// The Comment counter button
@property (nonatomic, strong) UIButton *commentCounter;

/// The like counter button
@property (nonatomic, strong) UIButton *likeCounter;

/// The photo displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

/// The Comment On display button
@property (nonatomic,readonly) UIButton *commentButton;

/// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<FTPhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
@end

/*!
 The protocol defines methods a delegate of a FTPhotoDetailsHeaderView should implement.
 */
@protocol FTPhotoDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(FTPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(FTPhotoDetailsHeaderView *)headerView didTapLocation:(UIButton *)button photo:(PFObject *)photo;

@end
