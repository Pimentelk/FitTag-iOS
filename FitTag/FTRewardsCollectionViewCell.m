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
@end

@implementation FTRewardsCollectionViewCell
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = YES;
    }    
    return self;
}

- (void)setImage:(UIImage *)image {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height - 35.0f)];
    [imageView setBackgroundColor: [UIColor clearColor]];
    [imageView setImage:image];
    
    [self addSubview:imageView];
}

- (void)setLabelText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,self.frame.size.height - 35.0f,self.frame.size.width,35.0f)];
    label.textAlignment =  NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
    label.text = text;
    
    [self addSubview:label];
}

@end
