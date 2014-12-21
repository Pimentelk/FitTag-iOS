//
//  FTGallerySwiperView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTGallerySwiperView.h"

#define DASH_IMAGE @"dash"
#define DASH_WIDTH 8
#define DASH_HEIGHT DASH_WIDTH
#define PADDING_Y 0
#define PADDING_X 8
#define DASH_AREA PADDING_X + DASH_WIDTH

@interface FTGallerySwiperView() {
    NSMutableArray *dashes;
    int position;
}
@end

@implementation FTGallerySwiperView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        dashes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setNumberOfDashes:(int)numberOfDashes {
    
    //NSLog(@"self.count: %d",numberOfDashes);
    
    position = numberOfDashes - 1; // Last element position
    
    if (dashes.count > 0) { // if dashes is > 0 remove all imageview from the superview
        for (UIImageView *imageView in dashes) {
            [imageView removeFromSuperview];
        }
    }
    
    // remove all objects from array
    [dashes removeAllObjects];
    
    for (int i = 1; i <= numberOfDashes; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        if (i == 1) {
            [imageView setBackgroundColor:FT_RED];
        } else {
            [imageView setBackgroundColor:[UIColor whiteColor]];
        }
        
        [imageView setClipsToBounds:YES];
        [imageView.layer setBorderWidth:0.4];
        [imageView.layer setBorderColor:[FT_RED CGColor]];
        [imageView.layer setCornerRadius:CORNERRADIUS(DASH_WIDTH)];
        [imageView setFrame:CGRectMake((DASH_AREA * i), PADDING_Y, DASH_WIDTH, DASH_HEIGHT)];
        [dashes addObject:imageView];
        [self addSubview:imageView];
    }
}

- (void)onGallerySwipedLeft:(NSInteger)page {
    [self onGallerySwipe:page];
}

- (void)onGallerySwipedRight:(NSInteger)page {
    [self onGallerySwipe:page];
}

- (void)onGallerySwipe:(NSInteger)page {
    
    for (UIView *dash in dashes) {
        [UIView animateWithDuration:0.2 animations:^{
            [dash setBackgroundColor:[UIColor whiteColor]];
        }];
    }
    
    UIImageView *imageView = [dashes objectAtIndex:page];
    [UIView animateWithDuration:0.2 animations:^{
        [imageView setBackgroundColor:FT_RED];
    }];
}

@end
