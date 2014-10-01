//
//  FTRewardsDetailsHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailsHeaderView.h"
#import "FTProfileImageView.h"

@interface FTRewardsDetailsHeaderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PFObject *business;
@property (nonatomic, strong) PFObject *reward;
@property (nonatomic, strong) UIImageView *rewardPhoto;
@end

@implementation FTRewardsDetailsHeaderView
@synthesize business;
@synthesize rewardPhoto;
@synthesize reward;

-(id)initWithFrame:(CGRect)frame reward:(PFObject *)aReward {
    self = [super initWithFrame:frame];
    if (self) {
        self.reward = aReward;
        self.business = [self.reward objectForKey:kFTRewardsUserKey];
        
        self.containerView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.containerView];
        
        [self.containerView setBackgroundColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1]];
        
        UIImageView *profileHexagon = [self getProfileHexagon];
        FTProfileImageView *avatarImageView = [[FTProfileImageView alloc] initWithFrame:CGRectMake(6.0f, 8.0f, 50.0f, 50.0f)];
        [avatarImageView setFile:[self.business objectForKey:kFTUserProfilePicSmallKey]];
        [avatarImageView setBackgroundColor:[UIColor clearColor]];
        [avatarImageView setFrame:profileHexagon.frame];
        [avatarImageView.layer setMask:profileHexagon.layer.mask];
        [avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:avatarImageView];
        
        // UILabels
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(63.0f,13.0f,150.0f,18.0)];
        name.textAlignment =  NSTextAlignmentLeft;
        name.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        name.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
        name.text = [self.business objectForKey:kFTUserCompanyNameKey];
        [self.containerView addSubview:name];
        
        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(63.0f,30.0f,150.0f,18.0)];
        address.textAlignment =  NSTextAlignmentLeft;
        address.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        address.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
        address.text = [self.business objectForKey:kFTUserAddressKey];
        [self.containerView addSubview:address];
        
        TTTAttributedLabel *website = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(63.0f,47.0f,200.0f,18.0)];
        website.textAlignment =  NSTextAlignmentLeft;
        website.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
        website.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
        website.text = @"Website";
        website.delegate = self;
        NSRange range = [website.text rangeOfString:@"Website"];
        [website addLinkToURL:[NSURL URLWithString:[self.business objectForKey:kFTUserWebsiteKey]] withRange:range];
        
        [self.containerView addSubview:website];
        
        UILabel *mention = [[UILabel alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width - 110,3.0f,100.0f,25.0f)];
        mention.textAlignment =  NSTextAlignmentRight;
        mention.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(13.0)];
        mention.text = [self.business objectForKey:kFTUserDisplayNameKey];
        [self.containerView addSubview:mention];
        
        
        PFFile *file = [reward objectForKey:kFTRewardsImageKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                rewardPhoto = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                [rewardPhoto setFrame:CGRectMake(0.0f,73.0f,320.0f,320.0f)];
                [self.containerView addSubview:rewardPhoto];
                
                UITextView *description = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,rewardPhoto.frame.size.height + rewardPhoto.frame.origin.y,
                                                                                       rewardPhoto.frame.size.width,72.0f)];
                
                description.textAlignment =  NSTextAlignmentLeft;
                description.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
                description.backgroundColor = [UIColor whiteColor];
                description.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
                description.text = [reward objectForKey:kFTUserDescriptionKey];
                [self.containerView addSubview:description];
                
            } else {
                NSLog(@"Error trying to download image..");
            }
        }];
    }
    return self;
}

- (UIImageView *)getProfileHexagon{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake( 5.0f, 8.0f, 57.0f, 57.0f);
    imageView.backgroundColor = [UIColor redColor];
    
    CGRect rect = CGRectMake( 5.0f, 8.0f, 55.0f, 55.0f);
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = imageView.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
    CGFloat lcolumn = rect.size.width - sideWidth;
    CGFloat height = rect.size.height;
    CGFloat ty = (rect.size.height - height) / 2;
    CGFloat tmy = rect.size.height / 4;
    CGFloat bmy = rect.size.height - tmy;
    CGFloat by = rect.size.height;
    CGFloat rightmost = rect.size.width;
    
    [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
    
    [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
    
    hexagonMask.path = hexagonPath.CGPath;
    
    imageView.layer.mask = hexagonMask;
    [imageView.layer addSublayer:hexagonBorder];
    
    return imageView;
}

- (void)didTapUserButtonAction:(id)sender {
    
}

#pragma mark - TTTAttributedLabel()
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    NSLog(@"URL: %@",url);
    [[UIApplication sharedApplication] openURL:url];
}

@end
