//
//  UICollectionViewCell+FTRewardsCollectionViewCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsCollectionViewCell.h"

@interface FTRewardsCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation FTRewardsCollectionViewCell
@synthesize imageView;
@synthesize label;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        // Image
        CGSize frameSize = self.frame.size;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height - 35)];
        [imageView setBackgroundColor: [UIColor clearColor]];
        [self addSubview:imageView];
        
        // Label
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, frameSize.height - 35, frameSize.width, 35)];
        label.textAlignment =  NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor whiteColor];
        label.font = MULIREGULAR(22);
        [self addSubview:label];
    }    
    return self;
}

- (void)setImage:(UIImage *)image {
    [imageView setImage:image];
}

- (void)setLabelText:(NSString *)text {
    label.text = text;
}

@end
