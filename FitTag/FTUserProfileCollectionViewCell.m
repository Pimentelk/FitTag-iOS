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
@synthesize post;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = YES;

        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 2)];
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

- (void)setPost:(PFObject *)aPost {
    
    post = aPost;
    
    if (post) {
        [self loadImageView:[post objectForKey:kFTPostImageKey]];
    }
}

- (void)loadImageView:(PFFile *)file {
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            [imageView setImage:[UIImage imageWithData:data]];
            [self addSubview:imageView];
            
            // If video show playbutton
            if ([[post objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeVideo]) {
                
                CGSize frameSize = self.frame.size;
                
                UIImageView *playImageView = [[UIImageView alloc] initWithImage:IMAGE_PLAY_BUTTON];
                [playImageView setFrame:CGRectMake(0, 0, 25, 25)];
                [playImageView setCenter:CGPointMake(frameSize.width/2, frameSize.height/2)];
                [self addSubview:playImageView];
            }
            
        } else {
            NSLog(@"Error trying to download image..");
        }
    }];
}

@end
