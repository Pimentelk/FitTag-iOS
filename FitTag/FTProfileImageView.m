//
//  FTProfileImageViews.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTProfileImageView.h"

@interface FTProfileImageView ()
@property (nonatomic, strong) UIImageView *borderImageview;
@end

@implementation FTProfileImageView

@synthesize borderImageview;
@synthesize profileImageView;
@synthesize profileButton;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
        [self addSubview:self.borderImageview];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.borderImageview];
    
    self.profileImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.borderImageview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.profileImageView.layer.cornerRadius = CORNERRADIUS(self.frame.size.width);
    self.profileImageView.clipsToBounds = YES;
    self.borderImageview.layer.cornerRadius = CORNERRADIUS(self.frame.size.width);
    self.borderImageview.clipsToBounds = YES;
    self.profileButton.layer.cornerRadius = CORNERRADIUS(self.frame.size.width);
    self.profileButton.clipsToBounds = YES;
}

#pragma mark - FTProfileImageView

- (void)setFile:(PFFile *)file {    

    self.profileImageView.image = [UIImage imageNamed:IMAGE_PROFILE_DEFAULT];
    
    if (!file)
        return;
    
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
}

@end

