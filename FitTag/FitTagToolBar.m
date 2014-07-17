//
//  FitTagToolBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FitTagToolBar.h"
#import "NotificationsViewController.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "OffersViewController.h"

@implementation FitTagToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"FitTagToolBar::initWithFrame");
        
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    NSMutableArray *toolbarItems = [@[] mutableCopy];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notifications"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(viewNotifications)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(viewSearch)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"myprofile"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(viewMyProfile)]];
    [toolbarItems addObject:flexibleSpace];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"offers"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(viewOffers)]];
    
    [toolbar setTintColor:[UIColor colorWithRed:255.0/255.0
                                          green:0.0/255.0
                                           blue:0.0/255.0
                                          alpha:1.0]];
    
    [toolbar setItems:toolbarItems animated:NO];
    [toolbar setTranslucent:NO];
    
    [self addSubview:toolbar];
    
}

-(void)viewNotifications
{
    NSLog(@"FitTagToolBar::viewNotifications");
    
    // Show the interests view controller
    //NotificationsViewController *rootViewController = [[NotificationsViewController alloc] init];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];    
    //[self presentViewController:navController animated:YES completion:NULL];
}

-(void)viewSearch
{
    NSLog(@"FitTagToolBar::viewSearch");
    
    // Show the search view controller
    //SearchViewController *rootViewController = [[SearchViewController alloc] init];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
}

-(void)viewMyProfile
{
    NSLog(@"FitTagToolBar::viewMyProfile");
    
    // Show the profile view controller
    //ProfileViewController *rootViewController = [[ProfileViewController alloc] init];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
}

-(void)viewOffers
{
    NSLog(@"FitTagToolBar::viewOffers");
    
    // Show the offers view controller
    //OffersViewController *rootViewController = [[OffersViewController alloc] init];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
}

@end
