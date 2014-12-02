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

- (id)initWithFrame:(CGRect)frame AndMapItem:(PFObject *)item;

@end

/*!
 The protocol defines methods a delegate of a FTMapScrollViewItem should implement.
 All methods of the protocol are optional.
 */
@protocol FTMapScrollViewItemDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the scroll view item is tapped
 @param post the PFObject associated with this gesture
 */
- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem didTapPostItem:(UIButton *)button post:(PFObject *)aPost;

/*!
 Sent to the delegate when the gallery is tapped
 @param user the PFObject associated with this gesture
 */
- (void)mapScrollViewItem:(FTMapScrollViewItem *)mapScrollViewItem didTapUserItem:(UIButton *)button user:(PFUser *)aUser;

@end