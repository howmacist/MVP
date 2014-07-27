//
//  dashTableViewCell.h
//  finalFlows
//
//  Created by Matt Riddoch on 4/24/14.
//  Copyright (c) 2014 mattRiddoch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dashTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end
