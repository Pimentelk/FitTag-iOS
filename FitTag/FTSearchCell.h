//
//  UITableViewCell+FTSearchCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/7/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTSearchCellDelegate;
@interface FTSearchCell : UITableViewCell

@property (nonatomic, weak) id<FTSearchCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol FTSearchCellDelegate <NSObject>


@end