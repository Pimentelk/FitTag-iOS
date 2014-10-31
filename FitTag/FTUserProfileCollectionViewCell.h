//
//  FTUserProfileCollectionViewCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/5/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTUserProfileCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) PFObject *post;
@property (nonatomic, strong) PFUser *user;
@end
