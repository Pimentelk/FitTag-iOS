//
//  FTRewardsDetailsHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailHeaderView.h"
#import "FTProfileImageView.h"

@interface FTRewardsDetailHeaderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PFUser *business;
@property (nonatomic, strong) PFObject *reward;
@property (nonatomic, strong) UIImageView *rewardPhoto;

@property (nonatomic, strong) UILabel *businessName;
@property (nonatomic, strong) UILabel *businessAddress;
@property (nonatomic, strong) TTTAttributedLabel *businessWebsite;
@end

@implementation FTRewardsDetailHeaderView
@synthesize business;
@synthesize rewardPhoto;
@synthesize reward;
@synthesize businessName;
@synthesize businessAddress;
@synthesize businessWebsite;
@synthesize delegate;

-(id)initWithFrame:(CGRect)frame reward:(PFObject *)aReward {
    self = [super initWithFrame:frame];
    if (self) {
        self.reward = aReward;
        
        self.containerView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.containerView];
        
        [self.containerView setBackgroundColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1]];
        
        //UIImageView *profileHexagon = [self getProfileHexagon];
        FTProfileImageView *avatarImageView = [[FTProfileImageView alloc] initWithFrame:CGRectMake(6, 8, 50, 50)];
        [avatarImageView setBackgroundColor:[UIColor clearColor]];
        //[avatarImageView setFrame:profileHexagon.frame];
        //[avatarImageView.layer setMask:profileHexagon.layer.mask];
        [avatarImageView setFrame:CGRectMake(5, 8, 57, 57)];
        [avatarImageView.layer setCornerRadius:CORNERRADIUS(57)];
        [avatarImageView setClipsToBounds:YES];
        [avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:avatarImageView];
        
        // Business name
        businessName = [[UILabel alloc] initWithFrame:CGRectMake(63.0f,13.0f,150.0f,18.0)];
        businessName.textAlignment =  NSTextAlignmentLeft;
        businessName.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        businessName.font = BENDERSOLID(15);
        [self.containerView addSubview:businessName];
        
        // Business address
        businessAddress = [[UILabel alloc] initWithFrame:CGRectMake(63.0f,30.0f,150.0f,18.0)];
        businessAddress.textAlignment =  NSTextAlignmentLeft;
        businessAddress.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        businessAddress.font = BENDERSOLID(15);
        [self.containerView addSubview:businessAddress];
        
        // Business website
        businessWebsite = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(63.0f,47.0f,200.0f,18.0)];
        businessWebsite.textAlignment =  NSTextAlignmentLeft;
        businessWebsite.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        businessWebsite.font = BENDERSOLID(15);
        businessWebsite.text = @"Website";
        businessWebsite.delegate = self;
        NSRange range = [businessWebsite.text rangeOfString:@"Website"];
        
        [self.containerView addSubview:businessWebsite];
        
        UILabel *mention = [[UILabel alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width - 110,3.0f,100.0f,25.0f)];
        mention.textAlignment =  NSTextAlignmentRight;
        mention.font = BENDERSOLID(13);
        [self.containerView addSubview:mention];
        
        [[reward objectForKey:kFTRewardsUserKey] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                NSLog(@"object: %@",object);
                
                self.business = (PFUser *)object;
                
                // Set the avatar image
                [avatarImageView setFile:[self.business objectForKey:kFTUserProfilePicSmallKey]];
                
                // Set the business name
                businessName.text = [self.business objectForKey:kFTUserCompanyNameKey];
                
                // Set the business address
                businessAddress.text = [self.business objectForKey:kFTUserAddressKey];
                
                // set the website
                [businessWebsite addLinkToURL:[NSURL URLWithString:[self.business objectForKey:kFTUserWebsiteKey]] withRange:range];
                
                // handle
                mention.text = [self.business objectForKey:kFTUserDisplayNameKey];
            }
        }];
        
        
        PFFile *file = [reward objectForKey:kFTRewardsImageKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                rewardPhoto = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                [rewardPhoto setFrame:CGRectMake(0.0f,73.0f,320.0f,320.0f)];
                [self.containerView addSubview:rewardPhoto];
                
                UITextView *description = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,rewardPhoto.frame.size.height + rewardPhoto.frame.origin.y,
                                                                                       rewardPhoto.frame.size.width,72.0f)];
                
                description.textAlignment =  NSTextAlignmentLeft;
                description.userInteractionEnabled = NO;
                description.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
                description.backgroundColor = [UIColor whiteColor];
                description.font = BENDERSOLID(15);
                description.text = [reward objectForKey:kFTUserDescriptionKey];
                [self.containerView addSubview:description];
                
            } else {
                NSLog(@"Error trying to download image..");
            }
        }];
    }
    return self;
}

- (void)didTapUserButtonAction:(id)sender {
    if (self.business) {
        if (delegate && [delegate respondsToSelector:@selector(rewardsDetailHeaderView:didTapBusinessButton:business:)]){
            [delegate rewardsDetailHeaderView:self didTapBusinessButton:sender business:self.business];
        }
    }
}

#pragma mark - TTTAttributedLabel()
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    NSLog(@"URL: %@",url);
    [[UIApplication sharedApplication] openURL:url];
}

@end
