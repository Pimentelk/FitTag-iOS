//
//  PFTableViewCell+FTVideoDetailsHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@class PFImageView;
@protocol FTPostDetailsHeaderViewDelegate;
@interface FTPostDetailsHeaderView : UIView <UIScrollViewDelegate>


/*! @name Managing View Properties */

/// The movieplayer
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

/// The video button
@property (nonatomic, strong) UIButton *playButton;

/// The scrollview
@property (nonatomic, strong) UIScrollView *carousel;

/// The displayname button
@property (nonatomic, strong) UIButton *usernameRibbon;

/// The Comment counter button
@property (nonatomic, strong) UIButton *commentCounter;

/// The like counter button
@property (nonatomic, strong) UIButton *likeCounter;

/// The post displayed in the view
@property (nonatomic, strong, readonly) PFObject *post;

/// The post type in the view
@property (nonatomic, strong) NSString *type;

/// The Comment On display button
@property (nonatomic,readonly) UIButton *commentButton;

/// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<FTPostDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost type:(NSString *)aType;
- (id)initWithFrame:(CGRect)frame post:(PFObject*)aPost type:(NSString *)aType photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
@end

/*!
 The protocol defines methods a delegate of a FTPhotoDetailsHeaderView should implement.
 */
@protocol FTPostDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapImageInGalleryAction:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;


- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapLocation:(UIButton *)button post:(PFObject *)post;

@end