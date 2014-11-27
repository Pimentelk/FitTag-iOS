//
//  FTContactCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTContactCell.h"

@interface FTContactCell()
@end

@implementation FTContactCell
@synthesize delegate;
@synthesize contactLabel;
@synthesize selectUserButton;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;
        self.contentView.clipsToBounds = YES;
        
        // Follow/Unfollow Button
        selectUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_UNSELECTED] forState:UIControlStateNormal];
        [selectUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_SELECTED] forState:UIControlStateSelected];
        [selectUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_SELECTED] forState:UIControlStateHighlighted];
        [selectUserButton addTarget:self action:@selector(didTapSelectUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [selectUserButton setFrame:CGRectMake(self.frame.size.width - 60, 5, 30, 30)];
        [selectUserButton setSelected:NO];
        
        [self.contentView addSubview:selectUserButton];
    }
    
    return self;
}

- (void)setContactLabel:(UILabel *)label {
    contactLabel = label;
    [self.contentView addSubview:contactLabel];
}

- (void)didTapSelectUserButtonAction:(UIButton *)button {
    NSLog(@"didTapSelectUserButtonAction:");
    
    [button setSelected:![button isSelected]];
    
    if ([button isSelected]) {
        if (delegate && [delegate respondsToSelector:@selector(contactCell:didTapSelectButton:index:)]) {
            [delegate contactCell:self didTapSelectButton:button index:self.tag];
        }
    }
    
    if (![button isSelected]) {
        if (delegate && [delegate respondsToSelector:@selector(contactCell:didTapUnselectButton:index:)]) {
            [delegate contactCell:self didTapUnselectButton:button index:self.tag];
        }
    }
}

@end
