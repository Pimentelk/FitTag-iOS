//
//  FTLoadMoreCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLoadMoreCell.h"
#import "FTUtility.h"

@implementation FTLoadMoreCell

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView setBackgroundColor:[UIColor colorWithRed:FT_RED_COLOR_RED
                                                             green:FT_RED_COLOR_GREEN
                                                              blue:FT_RED_COLOR_BLUE
                                                             alpha:1.0f]];
        
        UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
        [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
        [loadMoreLabel setTextColor:[UIColor whiteColor]];
        [loadMoreLabel setFont:BENDERSOLID(16)];
        [loadMoreLabel setText:@"Load More..."];
        
        [self.contentView addSubview:loadMoreLabel];
        [self.contentView bringSubviewToFront:loadMoreLabel];
    }
    
    return self;
}
@end

