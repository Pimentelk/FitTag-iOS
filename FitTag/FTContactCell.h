//
//  FTContactCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTContactCellDelegate;

@interface FTContactCell : UITableViewCell

@property (nonatomic, strong) UILabel *contactLabel;
@property (nonatomic, strong) UIButton *selectUserButton;
@property (nonatomic, weak) id<FTContactCellDelegate> delegate;

@end

@protocol FTContactCellDelegate <NSObject>
@optional

- (void) contactCell:(FTContactCell *)contactCell didTapSelectButton:(UIButton *)button index:(NSInteger)index;

- (void) contactCell:(FTContactCell *)contactCell didTapUnselectButton:(UIButton *)button index:(NSInteger)index;

@end