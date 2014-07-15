//
//  MemberCellCollectionView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InspirationCellCollectionView : UICollectionViewCell
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UILabel *messageInterests;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) UIImage *image;
@property BOOL isSelectedToggle;
@end
