//
//  FTSearchHeaderView.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTSearchHeaderButtonsFilterShow = 0,
    FTSearchHeaderButtonsFilterHide = 1 << 0,
    FTSearchHeaderButtonsPopular = 1 << 1,
    FTSearchHeaderButtonsTrending = 1 << 2,
    FTSearchHeaderButtonsUsers = 1 << 3,
    FTSearchHeaderButtonsTags = 1 << 4,
    FTSearchHeaderButtonsAmbassadors = 1 << 5,
    FTSearchHeaderButtonsNearby = 1 << 6,
    FTSearchHeaderButtonsDefault = FTSearchHeaderButtonsFilterShow | FTSearchHeaderButtonsFilterHide | FTSearchHeaderButtonsPopular
    | FTSearchHeaderButtonsTrending | FTSearchHeaderButtonsUsers | FTSearchHeaderButtonsTags | FTSearchHeaderButtonsAmbassadors
    | FTSearchHeaderButtonsNearby
} FTSearchHeaderButtons;

@class PFImageView;
@protocol FTSearchHeaderViewDelegate;
@interface FTSearchHeaderView : UIView

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) FTSearchHeaderButtons buttons;

/*! @name Delegate */
@property (nonatomic,weak) id <FTSearchHeaderViewDelegate> delegate;

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(FTSearchHeaderButtons)otherButtons;
@end

@protocol FTSearchHeaderViewDelegate <NSObject>
@optional

@end