//
//  FLoutsideWrapper.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"
#import "insideWrapper.h"

@interface FLoutsideWrapper : JSONModel

@property (strong, nonatomic) insideWrapper* value;
@property (assign, nonatomic) NSString *name;

@end
