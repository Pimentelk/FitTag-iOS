//
//  FTPhotoPostDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTPostDetailsFooterViewDelegate;

@interface FTPostDetailsFooterView : UIView
@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UITextField *tagField;
@property (nonatomic, strong) UITextField *tagsArea;
@property (nonatomic) BOOL hideDropShadow;
@property (nonatomic,weak) id <FTPostDetailsFooterViewDelegate> delegate;
+ (CGRect)rectForView;
@end

@protocol FTPostDetailsFooterViewDelegate <NSObject>
@optional
-(void)facebookShareButton:(id)sender;
-(void)twitterShareButton:(id)sender;
-(void)sendPost:(id)sender;
@end
