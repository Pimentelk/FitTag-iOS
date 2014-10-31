//
//  FTPhotoDetailsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoDetailsHeaderView.h"
#import "FTPhotoDetailsFooterView.h"
#import "FTBaseTextCell.h"

@interface FTPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, FTPhotoDetailsHeaderViewDelegate, FTPhotoDetailsFooterViewDelegate, FTBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
