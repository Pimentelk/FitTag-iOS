//
//  DataCellCollectionView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/1/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface InterestCellCollectionView : UICollectionViewCell
@property (nonatomic,retain) UILabel *interestLabel;
- (BOOL)isSelectedToggle;
@end
