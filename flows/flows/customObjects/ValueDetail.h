//
//  ValueDetail.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"

@protocol ValueDetail

@end


@interface ValueDetail : JSONModel

@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *dateTime;

@end
