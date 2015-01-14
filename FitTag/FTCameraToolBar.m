//
//  FTCameraToolBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/9/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCameraToolBar.h"
#import "FTCamRollViewController.h"

@implementation FTCameraToolBar

@synthesize delegate;

-(void)drawRect:(CGRect)rect {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbar setBarTintColor:FT_RED];
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notifications"] style:UIBarButtonItemStyleBordered target:self action:@selector(loadCameraPreview)]];
    [toolbar setTintColor:[UIColor whiteColor]];
    [toolbar setItems:toolbarItems animated:NO];
    [toolbar setTranslucent:YES];
    
    [self addSubview:toolbar];
}

-(void)loadCameraPreview {
    //NSLog(@"FTCameraToolBar::loadCameraPreview");
    if ([self.delegate respondsToSelector:@selector(showCameraPreview)]) {
        [self.delegate showCameraPreview];
    }
}

@end
