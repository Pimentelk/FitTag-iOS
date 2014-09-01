//
//  FTPhotoPostDetailsFooterView.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"
#import "FTUtility.h"

@interface FTPostDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation FTPostDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;
@synthesize tagField;
@synthesize tagsArea;
@synthesize submitButton;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 200.0f)];
        mainView.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
        [self addSubview:mainView];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
        [mainView addSubview:commentBox];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 40.0f)];
        commentField.font = [UIFont systemFontOfSize:12.0f];
        commentField.returnKeyType = UIReturnKeyDefault;
        commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        commentField.backgroundColor = [UIColor whiteColor];
        commentField.placeholder = @" WRITE A CAPTION...";
        [commentField setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        [mainView addSubview:commentField];
        
        tagField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 30.0f)];
        tagField.font = [UIFont systemFontOfSize:12.0f];
        tagField.returnKeyType = UIReturnKeyDefault;
        tagField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        tagField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tagField.backgroundColor = [UIColor whiteColor];
        tagField.placeholder = @" TAG THIS...";
        [tagField setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        [mainView addSubview:tagField];
        
        tagsArea = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 78.0f, 320.0f, 25.0f)];
        tagsArea.font = [UIFont systemFontOfSize:12.0f];
        tagsArea.returnKeyType = UIReturnKeyDefault;
        tagsArea.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        tagsArea.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tagsArea.backgroundColor = [UIColor whiteColor];
        tagsArea.placeholder = @"";
        tagsArea.userInteractionEnabled = NO;
        [tagsArea setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        [mainView addSubview:tagsArea];
        
        UIButton *facebookButton = [UIButton buttonWithType: UIButtonTypeCustom];
        facebookButton.frame = CGRectMake(20.0f, 111.0f, 71.0f, 80.0f);
        [facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(facebookShareButton:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:facebookButton];
         
        UIButton *twitterButton = [UIButton buttonWithType: UIButtonTypeCustom];
        twitterButton.frame = CGRectMake(110.0f, 111.0f, 71.0f, 80.0f);
        [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateNormal];
        [twitterButton addTarget:self action:@selector(twitterShareButton:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:twitterButton];
        
        submitButton = [UIButton buttonWithType: UIButtonTypeCustom];
        submitButton.frame = CGRectMake(230.0f, 111.0f, 71.0f, 80.0f);
        [submitButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(sendPost:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:submitButton];
    }
    
    return self;
}

#pragma mark - FTDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 200);
}

#pragma mark - ()

-(void)facebookShareButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(facebookShareButton:)]){
        [self.delegate facebookShareButton:sender];
    }
}

-(void)twitterShareButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(twitterShareButton:)]){
        [self.delegate twitterShareButton:sender];
    }
}

-(void)sendPost:(id)sender{
    if ([self.delegate respondsToSelector:@selector(sendPost:)]){
        [self.delegate sendPost:sender];
    }
}
@end
