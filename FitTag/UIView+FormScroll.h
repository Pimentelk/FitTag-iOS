//
//  UIView+FormScroll.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (FormScroll)

-(void)scrollToY:(float)y;
-(void)scrollToView:(UIView *)view;
-(void)scrollElement:(UIView *)view toPoint:(float)y;

@end
