//
//  DataCellCollectionView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/1/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTInterestCell : UICollectionViewCell
@property (nonatomic,retain) UILabel *interestLabel;
- (void)setCellSelection;
- (void)clearCellSelected;
- (BOOL)isSelectedToggle;
@end
