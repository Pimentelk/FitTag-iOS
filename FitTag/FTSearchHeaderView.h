//
//  FTSearchHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@class PFImageView;
@protocol FTSearchHeaderViewDelegate;
@interface FTSearchHeaderView : UIView

/*! @name Delegate */
@property (nonatomic,weak) id <FTSearchHeaderViewDelegate> delegate;

/*! @name Searchbar */
@property (nonatomic, strong) UITextField *searchbar;

/*!
 Initializes the view with the specified frame
 */
- (id)initWithFrame:(CGRect)frame;

- (BOOL)isPopularButtonSelected;

- (BOOL)isTrendingButtonSelected;

- (BOOL)isUserButtonSelected;

- (BOOL)isBusinessButtonSelected;

- (BOOL)isAmbassadorButtonSelected;

- (BOOL)isNearbyButtonSelected;
@end

@protocol FTSearchHeaderViewDelegate <NSObject>
@optional
/*!
 Sent to the delegate when the frame size changes
 @param frame the CGRectMake associated with the size
 */
- (void)searchHeaderView:(FTSearchHeaderView *)searchHeaderView didChangeFrameSize:(CGRect)rect;

@end