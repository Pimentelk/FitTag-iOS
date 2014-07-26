//
//  FTPhotoDetailsFooterView.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTPhotoDetailsFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end
