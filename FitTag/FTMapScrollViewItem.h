//
//  FTAccountHeaderView+FTMapScrollViewItem.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTMapScrollViewItemDelegate;
@interface FTMapScrollViewItem : UIImageView

/*! @name Delegate */
@property (nonatomic, weak) id <FTMapScrollViewItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame place:(PFObject *)place;
//- (id)initWithFrame:(CGRect)frame AndMapItem:(PFObject *)item;

@end

/*!
 The protocol defines methods a delegate of a FTMapScrollViewItem should implement.
 All methods of the protocol are optional.
 */
@protocol FTMapScrollViewItemDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a gallery item is tapped
 @param place the PFObject associated with this gesture
 @param contact the PFUser assiciated with this gesture
 */
- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem didTapPlace:(PFObject *)place contact:(PFUser *)contact;

@end