//
//  InterestFlowLayout.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/6/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFlowLayout.h"

@implementation FTFlowLayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 1.0f;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end
