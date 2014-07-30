//
//  IAPHelper.h
//  flows
//
//  Created by Matt Riddoch on 7/29/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
