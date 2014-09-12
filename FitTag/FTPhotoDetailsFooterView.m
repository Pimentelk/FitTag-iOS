//
//  FTPhotoDetailsFooterView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoDetailsFooterView.h"
#import "FTUtility.h"

@interface FTPhotoDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation FTPhotoDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 200.0f)];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_bar"]];
        commentBox.frame = CGRectMake(0.0f, 0.0f, 320.0f, 43.0f);
        [mainView addSubview:commentBox];
        
        UIImageView *commentBoxButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"send_button"]];
        commentBoxButton.frame = CGRectMake(264.0f, 9.0f, 47.0f, 25.0f);
        [commentBox addSubview:commentBoxButton];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 7.0f, 6.0f, 252.0f, 31.0f)];
        commentField.font = [UIFont systemFontOfSize:12.0f];
        commentField.returnKeyType = UIReturnKeySend;
        commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [mainView addSubview:commentField];        
    }
    return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [FTUtility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}


#pragma mark - FTPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 69.0f);
}

@end

