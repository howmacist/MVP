//
//  centerViewController.m
//  flows
//
//  Created by Matt Riddoch on 7/26/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "centerViewController.h"
#import "dashTableViewCell.h"
#import "ISRefreshControl.h"

@interface centerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *addInstanceButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation centerViewController {
    ISRefreshControl *refreshControl;
}

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
    //_mainTable.contentInset = UIEdgeInsetsMake(-44.f, 0.f, -44.f, 0.f);
    _mainTable.tableHeaderView = nil;
    _mainTable.tableFooterView = nil;
    refreshControl = [[ISRefreshControl alloc] init];
    [refreshControl setBackgroundColor:[UIColor clearColor]];
    refreshControl.tintColor = [UIColor whiteColor];
    [_mainTable addSubview:refreshControl];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //[self toggleContents];
        [refreshControl endRefreshing];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}


#pragma mark - UITableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"dashCell";
    
    
    
    //FLintroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    dashTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[dashTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
    
}


#pragma mark - IBActions

- (IBAction)infoClicked:(id)sender {
    [self performSegueWithIdentifier:@"infoSegue" sender:self];
}

- (IBAction)addClicked:(id)sender {
    [self performSegueWithIdentifier:@"addSegue" sender:self];
}

@end
