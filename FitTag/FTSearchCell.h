//
//  FTSearchCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum{
    FTSearchCellTypeNone = 0,
    FTSearchCellTypePopular = 1 >> 0,
    FTSearchCellTypeTrending = 1 >> 1,
    FTSearchCellTypeUsers = 1 >> 2,
    FTSearchCellTypeHashTag = 1 >> 3,
    FTSearchCellTypeAmbassador = 1 >> 4,
    FTSearchCellTypeNearby = 1 >> 5,
    FTSearchCellTypeDefault = FTSearchCellTypePopular | FTSearchCellTypeTrending | FTSearchCellTypeUsers | FTSearchCellTypeHashTag | FTSearchCellTypeAmbassador | FTSearchCellTypeNearby
} FTSearchCellType;

@protocol FTSearchCellDelegate;
@interface FTSearchCell : PFTableViewCell

/// The object associated with this view
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger icon;
@property (nonatomic,assign) PFUser *user;
@property (nonatomic,strong) PFObject *post;
@property (nonatomic,weak) id <FTSearchCellDelegate> delegate;
@end

@protocol FTSearchCellDelegate <NSObject>
@optional
- (void)cellView:(PFTableViewCell *)cellView didTapTrendingCellIconButton:(UIButton *)button post:(PFObject *)post;
- (void)cellView:(PFTableViewCell *)cellView didTapPopularCellIconButton:(UIButton *)button post:(PFObject *)post;
- (void)cellView:(PFTableViewCell *)cellView didTapAmbassadorCellIconButton:(UIButton *)button post:(PFObject *)post;
- (void)cellView:(PFTableViewCell *)cellView didTapNearbyCellIconButton:(UIButton *)button post:(PFObject *)post;
- (void)cellView:(PFTableViewCell *)cellView didTapUserCellIconButton:(UIButton *)button user:(PFUser *)user;
- (void)cellView:(PFTableViewCell *)cellView didTapHashtagCellIconButton:(UIButton *)button post:(PFObject *)post;
- (void)cellView:(PFTableViewCell *)cellView didTapCellLabelButton:(UIButton *)button post:(PFObject *)post;
@end