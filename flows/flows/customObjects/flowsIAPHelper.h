//
//  flowsIAPHelper.h
//  flows
//
//  Created by Matt Riddoch on 7/29/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "IAPHelper.h"

@interface flowsIAPHelper : IAPHelper <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (flowsIAPHelper *)sharedInstance;

@end
