//
//  FTImageView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTImageView : UIImageView

@property (nonatomic, strong) UIImage *placeholderImage;

- (void) setFile:(PFFile *)file;

@end
