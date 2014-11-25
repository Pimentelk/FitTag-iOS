//
//  FTPhotoPostDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTPostDetailsFooterViewDelegate;

@interface FTPostDetailsFooterView : UIView
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UITextField *hashtagTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, weak) id <FTPostDetailsFooterViewDelegate> delegate;
@property (nonatomic) BOOL hideDropShadow;
+ (CGRect)rectForView;
@end

@protocol FTPostDetailsFooterViewDelegate <NSObject>
@optional
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapFacebookShareButton:(UIButton *)button;
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapSubmitPostButton:(UIButton *)button;
- (void)postDetailsFooterView:(FTPostDetailsFooterView *)postDetailsFooterView didTapTwitterShareButton:(UIButton *)button;
@end
