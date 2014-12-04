//
//  FTPhotoPostDetailsFooterView.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"
#import "FTUtility.h"

#define BUTTON_Y 70
#define BUTTON_W 71
#define BUTTON_H 80

@interface FTPostDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation FTPostDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;
@synthesize hashtagTextField;
@synthesize locationTextField;
@synthesize submitButton;
@synthesize facebookButton;
@synthesize twitterButton;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        mainView.backgroundColor = FT_GRAY;
        [self addSubview:mainView];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        [mainView addSubview:commentBox];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        commentField.font = [UIFont systemFontOfSize:12.0f];
        commentField.returnKeyType = UIReturnKeyDefault;
        commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        commentField.backgroundColor = [UIColor whiteColor];
        commentField.placeholder = @" WRITE A CAPTION...";
        [commentField setValue:[UIColor colorWithRed:154.0f/255.0f
                                               green:146.0f/255.0f
                                                blue:138.0f/255.0f
                                               alpha:1.0f]
                    forKeyPath:@"_placeholderLabel.textColor"];
        
        [mainView addSubview:commentField];
        
        /*
        hashtagTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 30.0f)];
        hashtagTextField.font = [UIFont systemFontOfSize:12.0f];
        hashtagTextField.returnKeyType = UIReturnKeyDefault;
        hashtagTextField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        hashtagTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        hashtagTextField.backgroundColor = [UIColor whiteColor];
        hashtagTextField.placeholder = @" TAG THIS...";
        [hashtagTextField setValue:[UIColor colorWithRed:154.0f/255.0f
                                                   green:146.0f/255.0f
                                                    blue:138.0f/255.0f
                                                   alpha:1.0f]
                        forKeyPath:@"_placeholderLabel.textColor"];
        
        [mainView addSubview:hashtagTextField];
        
        locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 78.0f, 320.0f, 25.0f)];
        locationTextField.font = [UIFont systemFontOfSize:12.0f];
        locationTextField.returnKeyType = UIReturnKeyDefault;
        locationTextField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        locationTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        locationTextField.backgroundColor = [UIColor whiteColor];
        locationTextField.placeholder = EMPTY_STRING;
        locationTextField.userInteractionEnabled = NO;
        [locationTextField setValue:[UIColor colorWithRed:154.0f/255.0f
                                                    green:146.0f/255.0f
                                                     blue:138.0f/255.0f alpha:1.0f]
                         forKeyPath:@"_placeholderLabel.textColor"];
        
        [mainView addSubview:locationTextField];
        */
        
        facebookButton = [UIButton buttonWithType: UIButtonTypeCustom];
        facebookButton.frame = CGRectMake(20.0f, BUTTON_Y, BUTTON_W, BUTTON_H);
        [facebookButton setBackgroundImage:[UIImage imageNamed:IMAGE_SOCIAL_FACEBOOKOFF] forState:UIControlStateNormal];
        [facebookButton setBackgroundImage:[UIImage imageNamed:IMAGE_SOCIAL_FACEBOOK] forState:UIControlStateSelected];
        [facebookButton addTarget:self action:@selector(didTapFacebookShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:facebookButton];
         
        twitterButton = [UIButton buttonWithType: UIButtonTypeCustom];
        twitterButton.frame = CGRectMake(110.0f, BUTTON_Y, BUTTON_W, BUTTON_H);
        [twitterButton setBackgroundImage:[UIImage imageNamed:IMAGE_SOCIAL_TWITTEROFF] forState:UIControlStateNormal];
        [twitterButton setBackgroundImage:[UIImage imageNamed:IMAGE_SOCIAL_TWITTER] forState:UIControlStateSelected];
        [twitterButton addTarget:self action:@selector(didTapTwitterShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:twitterButton];
        
        submitButton = [UIButton buttonWithType: UIButtonTypeCustom];
        submitButton.frame = CGRectMake(230.0f, BUTTON_Y, BUTTON_W, BUTTON_H);
        [submitButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(didTapSubmitPostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:submitButton];
    }
    
    return self;
}

#pragma mark - FTDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
}

#pragma mark - ()

-(void)didTapFacebookShareButtonAction:(UIButton *)button {
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [button setSelected:![button isSelected]];
        
        if ([button isSelected]) {
            if ([self.delegate respondsToSelector:@selector(postDetailsFooterView:didTapFacebookShareButton:)]){
                [self.delegate postDetailsFooterView:self didTapFacebookShareButton:button];
            }
        }
    } else {
        NSLog(@"is not linked with user...");
        [button setSelected:NO];
        [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                    message:@"Please visit the shared settings to link your FaceBook account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)didTapTwitterShareButtonAction:(UIButton *)button {
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [button setSelected:![button isSelected]];
        if ([button isSelected]) {
            if ([self.delegate respondsToSelector:@selector(postDetailsFooterView:didTapTwitterShareButton:)]){
                [self.delegate postDetailsFooterView:self didTapTwitterShareButton:button];
            }
        }
    } else {
        // Twitter account is not linked
        [[[UIAlertView alloc] initWithTitle:@"Twitter Not Linked"
                                    message:@"Please visit the shared settings to link your Twitter account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)didTapSubmitPostButtonAction:(UIButton *)button {
    
    if ([button isSelected])
        return;
    
    [button setSelected:YES];
    
    if ([self.delegate respondsToSelector:@selector(postDetailsFooterView:didTapSubmitPostButton:)]){
        [self.delegate postDetailsFooterView:self didTapSubmitPostButton:button];
    }
}
@end
