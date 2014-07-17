//
//  FLmainmodel.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/24/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"
#import "SourceInfoModel.h"
#import "VariableModel.h"
#import "ValuesModel.h"

@protocol FLmainmodel

@end


@interface FLmainmodel : JSONModel

@property (assign, nonatomic) NSString *name;
@property (strong, nonatomic) SourceInfoModel* sourceInfo;
@property (strong, nonatomic) VariableModel* variable;
@property (strong, nonatomic) NSArray<ValuesModel>* values;

@end
