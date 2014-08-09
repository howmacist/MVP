//
//  addInstanceViewController.h
//  flows
//
//  Created by Matt Riddoch on 7/26/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol addInstanceViewControllerDelegate;

@interface addInstanceViewController : UIViewController

@property (nonatomic, weak) id<addInstanceViewControllerDelegate> delegate;

@end

@protocol addInstanceViewControllerDelegate <NSObject>

- (void)addInstanceViewController:(addInstanceViewController*)viewController
             didChooseValue:(NSString*)value;

@end
