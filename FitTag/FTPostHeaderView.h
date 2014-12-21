//
//  FTPostHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTPostHeaderViewDelegate;
@interface FTPostHeaderView : UIView

/*! @name Delegate */
@property (nonatomic,weak) id <FTPostHeaderViewDelegate> delegate;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *post;

/*! @name Creating Post Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame;

- (void)setDate:(NSDate *)date;

@end

/*!
 The protocol defines methods a delegate of a FTPostHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol FTPostHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)postHeaderView:(FTPostHeaderView *)postHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end