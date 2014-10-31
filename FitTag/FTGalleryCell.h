//
//  PFTableViewCell+FTGalleryCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/3/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

typedef enum {
    FTGalleryCellButtonsNone = 0,
    FTGalleryCellButtonsLike = 1 << 0,
    FTGalleryCellButtonsComment = 1 << 1,
    FTGalleryCellButtonsUser = 1 << 2,
    FTGalleryCellButtonsMore = 1 << 3,
    FTGalleryCellButtonsDefault = FTGalleryCellButtonsLike | FTGalleryCellButtonsComment | FTGalleryCellButtonsUser | FTGalleryCellButtonsMore
} FTGalleryCellButtons;

@class PFImageView;
@protocol FTGalleryCellDelegate;
@interface FTGalleryCell : PFTableViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *commentCounter;
@property (nonatomic, strong) UIButton *likeCounter;
@property (nonatomic, strong) UIButton *galleryButton;
@property (nonatomic, strong) UIButton *usernameRibbon;

/*! @name Creating Gallery Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
//- (id)initWithFrame:(CGRect)frame buttons:(FTGalleryCellButtons)otherButtons;

/// The gallery associated with this view
@property (nonatomic,strong) PFObject *gallery;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) FTGalleryCellButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Gallery button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Gallery button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <FTGalleryCellDelegate> delegate;

/*! @name ScrollView */
@property (nonatomic,strong) UIScrollView *carousel;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated gallery is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end

/*!
 The protocol defines methods a delegate of a FTGalleryHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol FTGalleryCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the gallery is tapped
 @param gallery the PFObject associated with this gesture
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapImageInGalleryAction:(UIButton *)button gallery:(PFObject *)gallery;

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like gallery button is tapped
 @param gallery the PFObject for the gallery that is being liked or disliked
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapLikeGalleryButton:(UIButton *)button counter:(UIButton *)counter gallery:(PFObject *)gallery;

/*!
 Sent to the delegate when the comment on gallery button is tapped
 @param gallery the PFObject for the gallery that will be commented on
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapCommentOnGalleryButton:(UIButton *)button gallery:(PFObject *)gallery;

/*!
 Sent to the delegate when the more button is tapped
 @param the gallery for which the more button will be used
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapMoreButton:(UIButton *)button gallery:(PFObject *)gallery;

/*!
 Sent to the delegate when the more button is tapped
 @param the gallery for which the more button will be used
 */
- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapLocation:(UIButton *)button gallery:(PFObject *)gallery;

@end
