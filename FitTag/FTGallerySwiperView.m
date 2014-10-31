//
//  FTGallerySwiperView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTGallerySwiperView.h"

#define DASH_IMAGE @"dash"
#define DASH_WIDTH 9
#define DASH_HEIGHT 3
#define PADDING_Y 5
#define PADDING_X 1
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
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DASH_IMAGE]];
        if (i == 1) {
            [imageView setFrame:CGRectMake(0, PADDING_Y, DASH_WIDTH, DASH_HEIGHT)];
        } else {
            [imageView setFrame:CGRectMake((self.frame.size.width - (DASH_AREA * i)), PADDING_Y, DASH_WIDTH, DASH_HEIGHT)];
        }
        [dashes addObject:imageView];
        [self addSubview:imageView];
    }
}

- (void)onGallerySwipedLeft:(NSInteger)page {

    /* *****notes******* */
    // dashes.count is an array and needs to be compared by
    // subtracting one since pages starts at 0
    /* *****end notes******* */
    
    if (dashes.count > 0 || page <= dashes.count) {
        UIImageView *imageView = [dashes objectAtIndex:dashes.count - page];
        
        CGRect newFrame = imageView.frame;
        newFrame.origin.x = DASH_AREA * page;

        [UIView animateWithDuration:0.2
                         animations:^{
                             imageView.frame = newFrame;
                         }];
    }
}

- (void)onGallerySwipedRight:(NSInteger)page {
    
    if (dashes.count > 0 || dashes.count <= page) {
        if ([dashes objectAtIndex:page]) {
            UIImageView *imageView = [dashes objectAtIndex:dashes.count - page - 1];
            
            CGRect newFrame = imageView.frame;
            newFrame.origin.x = self.frame.size.width - ((DASH_AREA * (dashes.count - (page + 1)) + 1));
            
            [UIView animateWithDuration:0.2
                             animations:^{
                                 imageView.frame = newFrame;
                             }];
        }
    }
}

@end
