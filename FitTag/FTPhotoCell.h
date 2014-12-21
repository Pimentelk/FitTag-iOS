//
//  PhotoCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTPhotoCellButtonsNone = 0,
    FTPhotoCellButtonsLike = 1 << 0,
    FTPhotoCellButtonsComment = 1 << 1,
    FTPhotoCellButtonsUser = 1 << 2,
    FTPhotoCellButtonsMore = 1 << 3,
    FTPhotoCellButtonsDefault = FTPhotoCellButtonsLike | FTPhotoCellButtonsComment | FTPhotoCellButtonsUser | FTPhotoCellButtonsMore
} FTPhotoCellButtons;

@class PFImageView;
@protocol FTPhotoCellDelegate;

@interface FTPhotoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *commentCounter;
@property (nonatomic, strong) UIButton *likeCounter;
@property (nonatomic, strong) UIButton *photoButton;
//@property (nonatomic, strong) UIButton *usernameRibbon;

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
//- (id)initWithFrame:(CGRect)frame buttons:(FTPhotoCellButtons)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) FTPhotoCellButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Photo button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <FTPhotoCellDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end

/*!
 The protocol defines methods a delegate of a FTPhotoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol FTPhotoCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like photo button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLikePhotoButton:(UIButton *)button counter:(UIButton *)counter photo:(PFObject *)photo;

/*!
 Sent to the delegate when the like counter button is tapped
 @param button the button for the photo that tracks likes
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLikeCountButton:(UIButton *)button photo:(PFObject *)photo;


/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

/*!
 Sent to the delegate when the more button is tapped
 @param the photo for which the more button will be used
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapMoreButton:(UIButton *)button photo:(PFObject *)photo;


/*!
 Sent to the delegate when the location is tapped
 @param the video for which the location button will be used
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLocation:(id)sender photo:(PFObject *)photo;

/*!
 Sent to the delegate when the photo button is tapped
 @param the button for which the tap was registered
 */
- (void)photoCellView:(FTPhotoCell *)photoCellView didTapPhotoButton:(UIButton *)button;

@end
