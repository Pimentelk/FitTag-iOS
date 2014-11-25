//
//  CollectionHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCollectionHeaderView.h"

@implementation FTCollectionHeaderView
@synthesize messageHeader;
@synthesize messageText;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)setMessageHeader:(UILabel *)aMessageHeader {
    messageHeader = aMessageHeader;    
    [self addSubview:self.messageHeader];
}

- (void)setMessageText:(UILabel *)aMessageText {
    messageText = aMessageText;
    [self addSubview:self.messageText];
}

@end
