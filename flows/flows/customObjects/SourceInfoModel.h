//
//  SourceInfoModel.h
//  rivFlow
//
//  Created by Matt Riddoch on 2/25/14.
//  Copyright (c) 2014 Matt Riddoch. All rights reserved.
//

#import "JSONModel.h"

@protocol SourceInfoModel

@end

@interface SourceInfoModel : JSONModel

@property (assign, nonatomic) NSString *siteName;


@end
