//
//  FTCameraToolBar.h
//  FitTag
//
//  Created by Kevin Pimentel on 8/9/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTCameraToolBarDelegate <UIToolbarDelegate>
@required
-(void)showCameraPreview;
@end

@interface FTCameraToolBar : UIToolbar
@property (weak, nonatomic) id <FTCameraToolBarDelegate> delegate;
@end
