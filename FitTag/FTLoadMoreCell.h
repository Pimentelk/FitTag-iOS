//
//  FTLoadMoreCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTLoadMoreCell : UITableViewCell

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *separatorImageTop;
@property (nonatomic, strong) UIImageView *separatorImageBottom;
@property (nonatomic, strong) UIImageView *loadMoreImageView;

@property (nonatomic, assign) BOOL hideSeparatorTop;
@property (nonatomic, assign) BOOL hideSeparatorBottom;

@property (nonatomic) CGFloat cellInsetWidth;

@end
