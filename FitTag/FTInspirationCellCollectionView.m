//
//  MemberCellCollectionView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInspirationCellCollectionView.h"

@interface FTInspirationCellCollectionView()

@end

@implementation FTInspirationCellCollectionView
@synthesize imageView;
@synthesize image;
//@synthesize imageFile;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Show gray line
        UIView *lineViewGray = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        lineViewGray.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineViewGray];
        
        // Show white line
        UIView *lineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, 1)];
        lineViewWhite.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineViewWhite];
        
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 195, 40)];
        //self.message = [[UILabel alloc] init];
        [self.message setTextAlignment: NSTextAlignmentLeft];
        [self.message setTextColor: [UIColor blackColor]];
        [self.message setFont:BENDERSOLID(14)];
        //[self.message setBackgroundColor:[UIColor blueColor]];
        [self addSubview: self.message];
        
        self.messageInterests = [[UILabel alloc] initWithFrame:CGRectMake(self.message.frame.size.width, 5, frame.size.width - self.message.frame.size.width, 40)];
        //self.messageInterests = [[UILabel alloc] init];
        [self.messageInterests setFont:[UIFont systemFontOfSize:11]];
        [self.messageInterests setTextAlignment: NSTextAlignmentLeft];
        [self.messageInterests setTextColor: [UIColor redColor]];
        //[self.messageInterests setBackgroundColor:[UIColor yellowColor]];
        [self.messageInterests setAdjustsFontSizeToFitWidth:NO];
        [self.messageInterests setLineBreakMode:NSLineBreakByTruncatingHead];
        [self.messageInterests setNumberOfLines:0];
        [self.messageInterests setFont:BENDERSOLID(14)];
        [self.messageInterests sizeThatFits:CGSizeMake(self.message.frame.size.width, FLT_MAX)];
        [self addSubview: self.messageInterests];
        
        self.isSelectedToggle = NO;
        
        imageView = [[PFImageView alloc] initWithFrame:CGRectMake(8, 37, 52, 52)];
        imageView.backgroundColor = [UIColor clearColor];
        
        UIImageView *profileHexagon = [FTUtility getProfileHexagonWithFrame:imageView.frame];
        imageView.frame = profileHexagon.frame;
        imageView.layer.mask = profileHexagon.layer.mask;
        
        [self addSubview:imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)aImage {    
    
    if (!aImage) {
        NSLog(@"image nil..");
        return;
    }
    
    image = aImage;
    
    [imageView setAlpha:0];
    [imageView setImage:aImage];
    
    [UIView animateWithDuration:0.5 animations:^{
        [imageView setAlpha:1];
    }];
}

@end
