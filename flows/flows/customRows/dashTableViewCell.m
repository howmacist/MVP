//
//  dashTableViewCell.m
//  finalFlows
//
//  Created by Matt Riddoch on 4/24/14.
//  Copyright (c) 2014 mattRiddoch. All rights reserved.
//

#import "dashTableViewCell.h"

@implementation dashTableViewCell

@synthesize titleLabel;
@synthesize locationLabel;
@synthesize resultLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
