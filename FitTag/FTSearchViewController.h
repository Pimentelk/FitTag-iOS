//
//  FTSearchViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/6/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchCell.h"
#import "FTTimelineViewController.h"
#import "FTLoadMoreCell.h"

typedef enum {
    FTSearchQueryTypeNone = 0,
    FTSearchQueryTypeUser = 1 << 0,
    FTSearchQueryTypeTrending = 1 << 1,
    FTSearchQueryTypeNearby = 1 << 2,
    FTSearchQueryTypeHashtag = 1 << 3,
    FTSearchQueryTypeMention = 1 << 4,
    FTSearchQueryTypePopular = 1 << 5,
    FTSearchQueryTypeFitTag = FTSearchQueryTypeHashtag,
} FTSearchQueryType;

@interface FTSearchViewController : FTTimelineViewController <UISearchBarDelegate>

@property (nonatomic, assign) FTSearchQueryType searchQueryType;
@property (nonatomic, strong) NSString *searchString;

@end