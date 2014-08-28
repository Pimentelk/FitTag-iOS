//
//  FTPhotoPostDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTPhotoPostDetailsFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UITextField *tagField;
@property (nonatomic, strong) UITextField *tagsArea;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end
