//
//  UITableViewCell+FTInviteCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFollowCell.h"

#define LABEL_PADDING_TOP 15.0f
#define LABEL_PADDING 5.0f
#define PROFILE_IMAGE_WIDTH 56.0f
#define PROFILE_IMAGE_HEIGHT 56.0f
#define ANIMATION_DURATION 0.3f
#define LABEL_HEIGHT 15.0f
#define FOLLOW_BUTTON_WIDTH 64.0f
#define PROFILE_IMAGE_X 10.0f

@interface FTFollowCell()
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *handleLabel;
@end

@implementation FTFollowCell
@synthesize user;
@synthesize delegate;
@synthesize profileImageView;
@synthesize titleLabel;
@synthesize handleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setClipsToBounds:YES];
        [self.imageView setClipsToBounds:YES];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                                             green:FT_GRAY_COLOR_GREEN
                                                              blue:FT_GRAY_COLOR_BLUE alpha:1.0f]];
        
        self.imageView.alpha = 0.0f;
        self.imageView.image = nil;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(didTapProfileImageAction:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        
        // ImageView Placeholder
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_IMAGE_X, 4, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        self.profileImageView.backgroundColor = [UIColor redColor];
        self.profileImageView.alpha = 0.0f;
        self.profileImageView.userInteractionEnabled = YES;
        [self.profileImageView addGestureRecognizer:tapGestureRecognizer];
        
        UIImageView *profileHexagon = [FTUtility getProfileHexagonWithFrame:profileImageView.frame];
        self.profileImageView.frame = profileHexagon.frame;
        self.profileImageView.layer.mask = profileHexagon.layer.mask;
        
        [self.contentView addSubview:profileImageView];
        
        CGFloat labelX = self.profileImageView.frame.size.width + self.profileImageView.frame.origin.x + LABEL_PADDING;
        CGFloat labelWidth = self.frame.size.width - self.profileImageView.frame.size.width - FOLLOW_BUTTON_WIDTH;
        
        // ImageView Title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, LABEL_PADDING_TOP + profileImageView.frame.origin.y,
                                                                    labelWidth, LABEL_HEIGHT)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.alpha = 0.0f;
        
        [self.contentView addSubview:self.titleLabel];
        
        CGFloat handleLabelY = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 1;
        
        // ImageView sub title
        self.handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, handleLabelY, labelWidth, LABEL_HEIGHT)];
        self.handleLabel.backgroundColor = [UIColor clearColor];
        self.handleLabel.textAlignment = NSTextAlignmentLeft;
        self.handleLabel.textColor = [UIColor colorWithRed:91/255.0f green:91/255.0f blue:91/255.0f alpha:1.0f];
        self.handleLabel.font = [UIFont systemFontOfSize:12];
        self.handleLabel.alpha = 0.0f;
        
        [self.contentView addSubview:self.handleLabel];
    }
    return self;
}

#pragma mark - ()

- (void)setUser:(PFUser *)aUser {
    
    user = aUser;
    
    // If the user has a profile picture available load it
    if ([self.user objectForKey:kFTUserProfilePicSmallKey]) {
        PFFile *file = [self.user objectForKey:kFTUserProfilePicSmallKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {                
                self.profileImageView.alpha = 0.0f;
                self.profileImageView.image = [UIImage imageWithData:data];
                
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    self.profileImageView.alpha = 1.0f;
                }];
            }
        }];
    } else {
        self.profileImageView.alpha = 0.0f;
        self.profileImageView.image = [UIImage imageNamed:IMAGE_PROFILE_EMPTY];
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.profileImageView.alpha = 1.0f;
        }];
    }
    
    self.titleLabel.alpha = 0.0f;
    self.handleLabel.alpha = 0.0f;
    
    NSString *firstname = EMPTY_STRING;
    if ([self.user objectForKey:kFTUserFirstnameKey]) {
        if (![[self.user objectForKey:kFTUserFirstnameKey] isEqualToString:EMPTY_STRING]) {
            firstname = [self.user objectForKey:kFTUserFirstnameKey];
        }
    }
    
    NSString *lastname = EMPTY_STRING;
    if ([self.user objectForKey:kFTUserLastnameKey]) {
        if (![[self.user objectForKey:kFTUserLastnameKey] isEqualToString:EMPTY_STRING]) {
            lastname = [self.user objectForKey:kFTUserLastnameKey];
        }
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",firstname,lastname];
        self.titleLabel.alpha = 1.0f;
        
        self.handleLabel.text = [NSString stringWithFormat:@"%@",[self.user objectForKey:kFTUserDisplayNameKey]];
        self.handleLabel.alpha = 1.0f;
    }];    
}

#pragma mark - FTFollowCellDelegate

- (void)didTapProfileImageAction:(id)sender {
    NSLog(@"%@::didTapProfileImageAction:",VIEWCONTROLLER_FOLLOW_CELL);
    
    NSLog(@"user = %@",user);
    
    if (delegate && [delegate respondsToSelector:@selector(followCell:didTapProfileImage:user:)]) {
        [delegate followCell:self didTapProfileImage:sender user:user];
    }
}

- (void)didTapFollowButtonAction:(UIButton *)button {
    NSLog(@"%@::didTapFollowButtonAction:",VIEWCONTROLLER_FOLLOW_CELL);
    if (delegate && [delegate respondsToSelector:@selector(followCell:didTapFollowButton:user:)]) {
        [delegate followCell:self didTapFollowButton:button user:user];
    }
}

@end
