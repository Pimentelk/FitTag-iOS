//
//  PhotoCellCollectionView.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "PhotoCellCollectionView.h"

@interface PhotoCellCollectionView()

@end

@implementation PhotoCellCollectionView

@synthesize photoImageView;

- (id)initWithFrame:(CGRect)frame
{
    //NSLog(@"PhotoCellCollectionView::initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 104.0f, 104.0f)];
        [self.contentView addSubview:self.photoImageView];
    }
    return self;
}

- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    //self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
