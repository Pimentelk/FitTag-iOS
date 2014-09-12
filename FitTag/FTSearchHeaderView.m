//
//  FTSearchHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchHeaderView.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTUtility.h"

@interface FTSearchHeaderView()
@property (nonatomic, strong) UIView *containerView;
@end

@implementation FTSearchHeaderView
@synthesize containerView;
@synthesize buttons;

- (id)initWithFrame:(CGRect)frame buttons:(FTSearchHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [FTSearchHeaderView validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        UIImage *image = [FTSearchHeaderView imageWithImage:[UIImage imageNamed:@"username_ribbon"] scaledToSize:CGSizeMake(320.0f, 35.0f)];
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:image]];
        
        if (self.buttons & FTSearchHeaderButtonsFilterShow) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsFilterHide) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsPopular) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsTrending) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsUsers) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsTags) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsAmbassadors) {
            
        }
        
        if (self.buttons & FTSearchHeaderButtonsNearby) {
            
        }
    }
    return self;
}

#pragma mark - ()

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)validateButtons:(FTSearchHeaderButtons)buttons {
    if (buttons == FTSearchHeaderButtonsFilterShow) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing FTSearchHeaderView."];
    }
}

@end
