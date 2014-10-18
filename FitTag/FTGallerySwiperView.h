//
//  FTGallerySwiperView.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTGallerySwiperView : UIView
@property (nonatomic, assign) int numberOfDashes;
- (id)initWithFrame:(CGRect)frame;
- (void)onGallerySwipedRight:(NSInteger)page;
- (void)onGallerySwipedLeft:(NSInteger)page;
@end
