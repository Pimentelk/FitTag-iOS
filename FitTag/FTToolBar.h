//
//  FitTagToolBar.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTToolBarDelegate <UIToolbarDelegate>
@required
-(void)viewNotifications:(id)sender;
-(void)viewSearch:(id)sender;
-(void)viewMyProfile:(id)sender;
-(void)viewOffers:(id)sender;
@end

@interface FTToolBar : UIToolbar
@property (weak, nonatomic) id <FTToolBarDelegate> delegate;
@end