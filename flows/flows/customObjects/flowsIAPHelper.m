//
//  flowsIAPHelper.m
//  flows
//
//  Created by Matt Riddoch on 7/29/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "flowsIAPHelper.h"

@implementation flowsIAPHelper

+ (flowsIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static flowsIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.flowsapps.upgrade",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}



@end
