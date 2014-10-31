//
//  FTVideoCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/31/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTVideoCellButtonsNone = 0,
    FTVideoCellButtonsLike = 1 << 0,
    FTVideoCellButtonsComment = 1 << 1,
    FTVideoCellButtonsUser = 1 << 2,
    FTVideoCellButtonsMore = 1 << 3,
    FTVideoCellButtonsPlay = 1 << 4,
    FTVideoCellButtonsDefault = FTVideoCellButtonsLike | FTVideoCellButtonsComment | FTVideoCellButtonsUser | FTVideoCellButtonsMore | FTVideoCellButtonsPlay
} FTVideoCellButtons;

@class PFImageView;
@protocol FTVideoCellDelegate;

@interface FTVideoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *commentCounter;
@property (nonatomic, strong) UIButton *likeCounter;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *usernameRibbon;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;


/*! @name Creating Video Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
//- (id)initWithFrame:(CGRect)frame buttons:(FTVideoCellButtons)otherButtons;

/// The video associated with this view
@property (nonatomic,strong) PFObject *video;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) FTVideoCellButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Play Video button
@property (nonatomic,readonly) UIButton *playButton;

/// The Like Video button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Video button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <FTVideoCellDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated video is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end

/*!
 The protocol defines methods a delegate of a FTVideoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol FTVideoCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like video button is tapped
 @param video the PFObject for the video that is being liked or disliked
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapLikeVideoButton:(UIButton *)button counter:(UIButton *)counter video:(PFObject *)video;

/*!
 Sent to the delegate when the comment on video button is tapped
 @param video the PFObject for the video that will be commented on
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapCommentOnVideoButton:(UIButton *)button video:(PFObject *)video;

/*!
 Sent to the delegate when the more button is tapped
 @param the video for which the more button will be used
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapMoreButton:(UIButton *)button video:(PFObject *)video;


/*!
 Sent to the delegate when the more button is tapped
 @param the video for which the more button will be used
 */
//- (void)videoCellView:(FTVideoCell *)videoCellView didTapPlayButton:(UIButton *)button forVideoFile:(PFFile *)videoFile;


/*!
 Sent to the delegate when the location is tapped
 @param the video for which the location button will be used
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapLocation:(id)sender video:(PFObject *)video;

/*!
 Sent to the delegate when the video button is tapped
 @param the button for which the tap was registered
 */
- (void)videoCellView:(FTVideoCell *)videoCellView didTapVideoButton:(UIButton *)button;

@end

