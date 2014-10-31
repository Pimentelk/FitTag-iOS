//
//  FTUserProfileCollectionViewCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/5/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTUserProfileCollectionViewCell.h"

@interface FTUserProfileCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation FTUserProfileCollectionViewCell
@synthesize imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = YES;

        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height - 2)];
        [imageView setBackgroundColor: [UIColor clearColor]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
    }
    return self;
}

- (void)setUser:(PFUser *)user {
    if (user) {
        [self loadImageView:[user objectForKey:kFTUserProfilePicSmallKey]];
    }
}

- (void)setPost:(PFObject *)post {    
    if (post) {
        [self loadImageView:[post objectForKey:kFTPostImageKey]];
    }
}

- (void)loadImageView:(PFFile *)file {
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            [imageView setImage:[UIImage imageWithData:data]];
            [self addSubview:imageView];
        } else {
            NSLog(@"Error trying to download image..");
        }
    }];
}

@end
