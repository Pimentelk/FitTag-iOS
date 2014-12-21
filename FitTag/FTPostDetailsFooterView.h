//
//  FTPhotoPostDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTPostDetailsFooterViewDelegate;

@interface FTPostDetailsFooterView : UIView <UITextViewDelegate>

@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UITextView *commentView;
@property (nonatomic, strong) UITextField *hashtagTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UISwitch *shareLocationSwitch;
@property (nonatomic) BOOL hideDropShadow;

@property (nonatomic, weak) id<FTPostDetailsFooterViewDelegate> delegate;

+ (CGRect)rectForView;

@end

@protocol FTPostDetailsFooterViewDelegate <NSObject>
@optional
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapFacebookShareButton:(UIButton *)button;
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapSubmitPostButton:(UIButton *)button;
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapTwitterShareButton:(UIButton *)button;
@end
