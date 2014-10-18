//
//  PFTableViewCell+FTAccountHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@class PFImageView;
@protocol FTAccountHeaderViewDelegate;
@interface FTAccountHeaderView : UIView
/*! @name Delegate */
@property (nonatomic,weak) id <FTAccountHeaderViewDelegate> delegate;
@end

@protocol FTAccountHeaderViewDelegate <NSObject>
@optional
/*!
 Sent to the delegate when the frame size changes
 @param frame the CGRectMake associated with the size
 */
- (void)accountHeaderView:(FTAccountHeaderView *)accountHeaderView didChangeFrameSize:(CGRect)rect;
@end