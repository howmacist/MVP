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
#import "MONActivityIndicatorView.h"
#import <StoreKit/StoreKit.h>
#import "flowsIAPHelper.h"
#import "addInstanceViewController.h"
#import "FLoutsideWrapper.h"
#import "mySidePanelViewController.h"
#import "UIViewController+JASidePanel.h"

@interface centerViewController () <UITableViewDelegate, UITableViewDataSource, MONActivityIndicatorViewDelegate, addInstanceViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addInstanceButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation centerViewController {
    ISRefreshControl *refreshControl;
    NSMutableArray *chosenObjectArray;
    NSMutableArray *currentResultArray;
    NSMutableArray *resultSetArray;
    NSMutableArray *resultForGraphs;
    MONActivityIndicatorView *indicatorView;
    NSArray *_products;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidLaunch:)
                                                 name:@"didLoadOne"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.center = self.view.center;
    indicatorView.numberOfCircles = 3;
    indicatorView.radius = 20;
    //indicatorView.delay = 0.05;
    indicatorView.duration = 0.6;
    [self.view addSubview:indicatorView];
    //[indicatorView startAnimating];
    
    _mainTable.allowsMultipleSelectionDuringEditing = NO;
    
    chosenObjectArray = [[NSMutableArray alloc] init];
    currentResultArray = [[NSMutableArray alloc] init];
    resultSetArray = [[NSMutableArray alloc] init];
    resultForGraphs = [[NSMutableArray alloc] init];
    //chosenObjectArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).chosenObjectArray;
    
    
    for (NSDictionary *chosenDict in chosenObjectArray) {
        NSLog(@"chosenDict %@", chosenDict);
    }
    
    _mainTable.tableHeaderView = nil;
    _mainTable.tableFooterView = nil;
    refreshControl = [[ISRefreshControl alloc] init];
    [refreshControl setBackgroundColor:[UIColor clearColor]];
    refreshControl.tintColor = [UIColor whiteColor];
    [_mainTable addSubview:refreshControl];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    
    _mainTable.hidden = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    chosenObjectArray = [[defaults objectForKey:@"chosenObjects"] mutableCopy];
    if (chosenObjectArray.count > 0) {
        [indicatorView startAnimating];
    }
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NSNotifications

- (void)appDidLaunch:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"didLoadOne"]){
        [indicatorView stopAnimating];
        chosenObjectArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).chosenObjectArray;
        currentResultArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).currentResultArray;
        resultSetArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).resultSetArray;
        resultForGraphs = ((AppDelegate *)[UIApplication sharedApplication].delegate).resultForGraphs;
        NSLog(@"app did recieve notification");
        if (refreshControl) {
            [refreshControl endRefreshing];
        }
        [_mainTable reloadData];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.5];
//        [_mainTable setAlpha:1.0];
//        [UIView commitAnimations];
        _mainTable.hidden = NO;
//        _mainTable.alpha = 0.0f;
//        [UIView beginAnimations:@"fadeInSecondView" context:NULL];
//        [UIView setAnimationDuration:1.5];
//        _mainTable.alpha = 1.0f;
//        [UIView commitAnimations];
        
    }
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}

#pragma mark - delegates

- (void)addInstanceViewController:(addInstanceViewController *)viewController didChooseValue:(NSString *)value{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(currentStationData)];
    [indicatorView startAnimating];
}

#pragma mark - In-app Purchase

- (void)reload {
    _products = nil;
    //[self.tableView reloadData];
    [[flowsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            NSLog(@"products %@", products);
            [[flowsIAPHelper sharedInstance] buyProduct:[_products firstObject]];
            
        }
        
    }];
    
    
    
}

#pragma mark - pull data

- (void)refresh
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(currentStationData)];
}

#pragma mark - UITableview delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (chosenObjectArray.count == 0) {
    //    return 1;
    //}else{
        return chosenObjectArray.count;
    //}
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"dashCell";
    
    
    
    //FLintroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    dashTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[dashTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionaryForCell = [chosenObjectArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = [dictionaryForCell objectForKey:@"siteName"];
    cell.locationLabel.text = [dictionaryForCell objectForKey:@"siteLocation"];
    for (NSDictionary *innerDictionary in currentResultArray) {
        if ([[dictionaryForCell objectForKey:@"siteNumber"] isEqualToString:[innerDictionary objectForKey:@"siteNumber"]]) {
            cell.resultLabel.text = [innerDictionary objectForKey:@"siteValue"];
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSDictionary *cellDict = [chosenObjectsArray objectAtIndex:indexPath.row];
    //pull detail data here!!!
    FLoutsideWrapper *wrapperToPass = [resultSetArray objectAtIndex:indexPath.row];
    NSString *resultForGraphString = [resultForGraphs objectAtIndex:indexPath.row];
    NSDictionary *dictionaryForCell = [chosenObjectArray objectAtIndex:indexPath.row];
    NSString *titleToPass = [dictionaryForCell objectForKey:@"siteName"];
    NSString *locationToPass = [dictionaryForCell objectForKey:@"siteLocation"];
    
    [self.sidePanelController showRightPanelAnimated:YES];
    
    NSDictionary *theInfo =
    [NSDictionary dictionaryWithObjectsAndKeys:wrapperToPass,@"wrapperToPass", resultForGraphString, @"resultForGraphString", titleToPass, @"titleToPass", locationToPass, @"locationToPass", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self
     userInfo:theInfo
     ];
}

#pragma mark - activity indicator

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    // For a random background color for a particular circle
//    CGFloat red   = (arc4random() % 256)/255.0;
//    CGFloat green = (arc4random() % 256)/255.0;
//    CGFloat blue  = (arc4random() % 256)/255.0;
//    CGFloat alpha = 1.0f;
//    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    UIColor *colorForActivity;
    
    switch (index) {
        case 0:
        {
            colorForActivity = [UIColor colorWithRed:6/255.0f green:119/255.0f blue:236/255.0f alpha:1.0f];
        }
            break;
        case 1:
        {
            colorForActivity = [UIColor colorWithRed:111/255.0f green:229/255.0f blue:125/255.0f alpha:1.0f];
        }
            break;
        case 2:
        {
            colorForActivity =  [UIColor colorWithRed:234/255.0f green:105/255.0f blue:71/255.0f alpha:1.0f];
        }
            break;
            
        default:
        {
            colorForActivity =  [UIColor colorWithRed:234/255.0f green:105/255.0f blue:71/255.0f alpha:1.0f];
        }
            break;
    }
    
    return colorForActivity;
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"addSegue"])
    {
        addInstanceViewController *targetController = [segue destinationViewController];
        targetController.delegate = self;
    }
    
}



#pragma mark - IBActions

- (IBAction)infoClicked:(id)sender {
    //[self performSegueWithIdentifier:@"infoSegue" sender:self];
    currentResultArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).currentResultArray;
    NSLog(@"test test");
}

- (IBAction)addClicked:(id)sender {
    if (chosenObjectArray.count < 5) {
        [self performSegueWithIdentifier:@"addSegue" sender:self];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL"
                                                        message:@"Dee dee doo doo."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Buy", nil];
        [alert show];
        
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
//        SKProduct *product = [_products firstObject];
//        NSLog(@"Buying %@...", product.productIdentifier);
//        [[flowsIAPHelper sharedInstance] buyProduct:product];
        [self reload];

        // do something here...
        
    }
}




@end
