//
//  AppDelegate.h
//  flows
//
//  Created by Matt Riddoch on 7/9/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *chosenObjectArray;
@property (strong, nonatomic) NSMutableArray *currentResultArray;
@property (strong, nonatomic) NSMutableArray *resultSetArray;

@end
