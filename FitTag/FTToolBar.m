//
//  FitTagToolBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTToolBar.h"
#import "FTActivityFeedViewController.h"
#import "FTProfileViewController.h"
#import "FTSearchViewController.h"
#import "FTOffersViewController.h"

@implementation FTToolBar

@synthesize delegate;

-(void)drawRect:(CGRect)rect
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    // Set toolbar buttons and spaces
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notifications"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didPressNotifications)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didPressSearch)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"myprofile"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didPressProfile)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"offers"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(didPressOffers)]];
    
    // Set the buttons color to red
    [toolbar setTintColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [toolbar setItems:toolbarItems animated:NO];
    [toolbar setTranslucent:NO];
    
    [self addSubview:toolbar];
    
}

-(void)didPressNotifications
{
    //NSLog(@"FitTagToolBar::didPressNotifications");
    if ([self.delegate respondsToSelector:@selector(viewNotifications)])
    {
        [self.delegate viewNotifications];
    }
}

-(void)didPressSearch
{
    //NSLog(@"FitTagToolBar::didPressSearch");
    if ([self.delegate respondsToSelector:@selector(viewSearch)])
    {
        [self.delegate viewSearch];
    }
}

-(void)didPressProfile
{
    //NSLog(@"FitTagToolBar::didPressProfile");
    if ([self.delegate respondsToSelector:@selector(viewMyProfile)])
    {
        [self.delegate viewMyProfile];
    }
}

-(void)didPressOffers
{
    //NSLog(@"FitTagToolBar::didPressOffers");
    if ([self.delegate respondsToSelector:@selector(viewOffers)])
    {
        [self.delegate viewOffers];
    }
}
@end
