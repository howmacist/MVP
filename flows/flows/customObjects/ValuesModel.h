//
//  ValuesModel.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"
#import "ValueDetail.h"

@protocol ValuesModel

@end


@interface ValuesModel : JSONModel

@property (strong, nonatomic) NSArray<ValueDetail>* value;

@end
