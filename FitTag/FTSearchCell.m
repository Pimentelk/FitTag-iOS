//
//  FTSearchCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchCell.h"

@interface FTSearchCell()
@property (nonatomic,strong) UILabel *displayName;
@property (nonatomic,strong) UIButton *iconView;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation FTSearchCell
@synthesize icon;
@synthesize displayName;
@synthesize iconView;
@synthesize delegate;
@synthesize post;
@synthesize user;
@synthesize tapGestureRecognizer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        FTSearchCellType otherCellType = FTSearchCellTypeDefault;
        [FTSearchCell validateCellType:otherCellType];
        icon = otherCellType;
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        
        displayName = [[UILabel alloc]initWithFrame:CGRectMake(61.0f, 0.0f, self.frame.size.width - 61.0f, self.frame.size.height)];
        [self.displayName setText:@"Loading.."];
        [self.contentView addSubview:displayName];
        
        iconView = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

#pragma mark - ()
- (void)setName:(NSString *)name{
    NSLog(@"FTSearchCell::setName:(NSString *)%@",name);
    displayName.text = name;
}

- (void)setPost:(PFObject *)aPost{
    NSLog(@"FTSearchCell::setPost:(PFObject *) %@",aPost);
    post = aPost;
}

- (void)setUser:(PFUser *)aUser{
    NSLog(@"FTSearchCell::setUser:(PFUser *) %@",aUser);
    user = aUser;
}

- (void)setIcon:(NSInteger)aIcon{
    NSLog(@"FTSearchCell::setIcon(NSInteger) %ld",(long)aIcon);
    
    //tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCellLabelButtonAction:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [displayName setUserInteractionEnabled:YES];
    
    if (aIcon == 0) {
        
    } else if(aIcon == 1){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_popular"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapPopularCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapPopularCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 56.0f)];
    } else if(aIcon == 2){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_trending"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapTrendingCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapTrendingCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 48.0f, 56.0f)];
    } else if(aIcon == 3){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_users"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapUserCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapUserCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 62.0f, 56.0f)];
    } else if(aIcon == 4){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_hashtag"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapHashtagCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapHashtagCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 56.0f, 56.0f)];
    } else if(aIcon == 5){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_ambassador"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapAmbassadorCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapAmbassadorCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 56.0f, 56.0f)];
    } else if(aIcon == 6){
        [iconView setBackgroundImage:[UIImage imageNamed:@"search_nearby"] forState:UIControlStateNormal];
        [iconView addTarget:self action:@selector(didTapNearbyCellIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tapGestureRecognizer addTarget:self action:@selector(didTapNearbyCellIconButtonAction:)];
        [iconView setFrame:CGRectMake(0.0f, 0.0f, 48.0f, 56.0f)];
    }
    
    [self.contentView addSubview:iconView];
    [displayName addGestureRecognizer:tapGestureRecognizer];
}

- (void)didTapTrendingCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapTrendingCellIconButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapTrendingCellIconButton:post:)]) {
            [delegate cellView:self didTapTrendingCellIconButton:sender post:self.post];
        }
    }
}

- (void)didTapPopularCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapPopularCellIconButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapPopularCellIconButton:post:)]) {
            [delegate cellView:self didTapPopularCellIconButton:sender post:self.post];
        }
    }
}

- (void)didTapAmbassadorCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapAmbassadorCellIconButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapAmbassadorCellIconButton:post:)]) {
            [delegate cellView:self didTapAmbassadorCellIconButton:sender post:self.post];
        }
    }
}

- (void)didTapNearbyCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapNearbyCellIconButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapNearbyCellIconButton:post:)]) {
            [delegate cellView:self didTapNearbyCellIconButton:sender post:self.post];
        }
    }
}

- (void)didTapUserCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapUserCellIconButtonAction:");
    if (self.user != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapUserCellIconButton:user:)]) {
            [delegate cellView:self didTapUserCellIconButton:sender user:self.user];
        }
    }
}

- (void)didTapHashtagCellIconButtonAction:(UIButton *)sender{
    NSLog(@"didTapHashtagCellIconButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapHashtagCellIconButton:post:)]) {
            [delegate cellView:self didTapHashtagCellIconButton:sender post:self.post];
        }
    }
}

- (void)didTapCellLabelButtonAction:(UIButton *)sender{
    NSLog(@"didTapCellLabelButtonAction:");
    if (self.post != nil) {
        if (delegate && [delegate respondsToSelector:@selector(cellView:didTapCellLabelButton:post:)]) {
            [delegate cellView:self didTapCellLabelButton:sender post:self.post];
        }
    }
}

+ (void)validateCellType:(FTSearchCellType)cellType {
    if (cellType == FTSearchCellTypeNone) {
        [NSException raise:NSInvalidArgumentException format:@"Cell type must be set before initializing FTSearchCellType."];
    }
}

@end
