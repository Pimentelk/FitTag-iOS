//
//  FTPhotoDetailsFooterView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoDetailsFooterView.h"
#import "FTUtility.h"

// Send button constants
#define SEND_BUTTON_WIDTH 47
#define SEND_BUTTON_HEIGHT 25
#define SEND_BUTTON_PADDING_RIGHT 6
#define SEND_BUTTON_PADDING_TOP 9

// MainView constants
#define MAIN_VIEW_X 0
#define MAIN_VIEW_Y 0
#define MAIN_VIEW_HEIGHT 200

// Comment box
#define COMMENT_BOX_X 0
#define COMMENT_BOX_Y 0
#define COMMENT_BOX_HEIGHT 43

// Comment field
#define COMMENT_FIELD_X 12
#define COMMENT_FIELD_Y 6
#define COMMENT_FIELD_WIDTH 242
#define COMMENT_FIELD_HEIGHT 31

// System font size
#define DEFAULT_SYSTEM_FONT_SIZE 12

@interface FTPhotoDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation FTPhotoDetailsFooterView
@synthesize commentField;
@synthesize commentSendButton;
@synthesize mainView;
@synthesize hideDropShadow;
@synthesize delegate;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake(MAIN_VIEW_X, MAIN_VIEW_Y, self.frame.size.width, 43)];
        mainView.backgroundColor = [UIColor clearColor];
        mainView.clipsToBounds = YES;
        [self addSubview:mainView];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_bar"]];
        commentBox.frame = CGRectMake(COMMENT_BOX_X, COMMENT_BOX_Y, self.frame.size.width, COMMENT_BOX_HEIGHT);
        [mainView addSubview:commentBox];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( COMMENT_FIELD_X, COMMENT_FIELD_Y, COMMENT_FIELD_WIDTH, COMMENT_FIELD_HEIGHT)];
        commentField.font = [UIFont systemFontOfSize:DEFAULT_SYSTEM_FONT_SIZE];
        commentField.returnKeyType = UIReturnKeySend;
        commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [mainView addSubview:commentField];
        
        commentSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentSendButton setEnabled:NO];
        [commentSendButton setBackgroundImage:[UIImage imageNamed:@"send_button"] forState:UIControlStateNormal];
        [commentSendButton addTarget:self action:@selector(didTapSendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [commentSendButton setFrame:CGRectMake(COMMENT_FIELD_X + COMMENT_FIELD_WIDTH, COMMENT_FIELD_Y + 3, SEND_BUTTON_WIDTH, SEND_BUTTON_HEIGHT)];
        [commentSendButton setUserInteractionEnabled:YES];
        
        [mainView addSubview:commentSendButton];
        [mainView bringSubviewToFront:commentSendButton];
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
    return CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,40);
}

#pragma mark - ()

- (void)didTapSendButtonAction:(UIButton *)button {
    NSLog(@"FTPhotoDetailsFooterView::didTapSendButtonAction");
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsFooterView:didTapSendButton:)]){
        [delegate photoDetailsFooterView:self didTapSendButton:button];
    }
}

@end

