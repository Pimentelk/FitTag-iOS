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
    
    self.profileImageView.frame = CGRectMake( 1.0f, 0.0f, self.frame.size.width - 2.0f, self.frame.size.height - 2.0f);
    self.borderImageview.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

#pragma mark - FTProfileImageView

- (void)setFile:(PFFile *)file {    
    if (!file) {
        return;
    }
    
    self.profileImageView.image = [UIImage imageNamed:IMAGE_PROFILE_DEFAULT];
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
}

@end

