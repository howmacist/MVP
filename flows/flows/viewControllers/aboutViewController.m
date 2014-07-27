//
//  aboutViewController.m
//  flows
//
//  Created by Matt Riddoch on 7/26/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "aboutViewController.h"

@interface aboutViewController ()
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation aboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBActions

- (IBAction)exitClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
