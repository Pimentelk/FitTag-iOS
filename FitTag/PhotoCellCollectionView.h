//
//  PhotoCellCollectionView.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoCellCollectionView : UICollectionViewCell
@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,retain) UIImageView *photoImageView;
@end
