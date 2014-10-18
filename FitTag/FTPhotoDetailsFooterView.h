//
//  FTPhotoDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTPhotoDetailsFooterViewDelegate;
@interface FTPhotoDetailsFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UIButton *commentSendButton;

/*! @name Delegate */
@property (nonatomic, strong) id<FTPhotoDetailsFooterViewDelegate> delegate;

@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end

@protocol FTPhotoDetailsFooterViewDelegate <NSObject>
@required
- (void)photoDetailsFooterView:(FTPhotoDetailsFooterView *)footerView didTapSendButton:(UIButton *)button;
@end