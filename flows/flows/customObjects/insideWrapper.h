//
//  insideWrapper.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"
#import "FLmainmodel.h"

@protocol insideWrapper

@end

@interface insideWrapper : JSONModel

@property (strong, nonatomic) NSArray<FLmainmodel>* timeSeries;

@end
