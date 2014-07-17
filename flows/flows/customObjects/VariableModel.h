//
//  VariableModel.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"

@protocol VariableModel

@end


@interface VariableModel : JSONModel

@property (strong, nonatomic) NSString *variableName;
@property (strong, nonatomic) NSString *variableDescription;
@property (strong, nonatomic) NSString *noDataValue;

@end
