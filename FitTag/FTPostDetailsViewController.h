//
//  PFTableViewCell+FTPostDetailViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsHeaderView.h"
#import "FTPhotoDetailsFooterView.h"
#import "FTBaseTextCell.h"

@interface FTPostDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, FTPostDetailsHeaderViewDelegate,
                                                                     FTPhotoDetailsFooterViewDelegate, FTBaseTextCellDelegate,
                                                                     UIActionSheetDelegate>

@property (nonatomic, strong) PFObject *post;
@property (nonatomic, strong) NSString *type;

- (id)initWithPost:(PFObject* )aPost AndType:(NSString *)aType;

@end
