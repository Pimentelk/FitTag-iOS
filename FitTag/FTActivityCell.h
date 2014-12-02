//
//  FTActivityCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBaseTextCell.h"
@protocol FTActivityCellDelegate;

@interface FTActivityCell : FTBaseTextCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

@end


/*!
 The protocol defines methods a delegate of a FTBaseTextCell should implement.
 */
@protocol FTActivityCellDelegate <FTBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(FTActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
