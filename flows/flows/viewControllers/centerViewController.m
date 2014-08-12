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
#import "FLminMaxFlows.h"
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
    NSMutableArray *twentyFiveHolderArray;
    NSMutableArray *seventyFiveHolderArray;
    NSMutableArray *finalValuesHolderArray;
    NSMutableArray *filteredMonthHolderArray;
    NSMutableArray *finalMonthHolderArray;
    NSMutableArray *finalTimeStampArray;
    //NSMutableArray *timeStampArray;
    NSArray<ValueDetail>* tempdetail;
    BOOL arrayBool;
    BOOL innerArrayBool;
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
    twentyFiveHolderArray = [[NSMutableArray alloc] init];
    seventyFiveHolderArray = [[NSMutableArray alloc] init];
    finalValuesHolderArray = [[NSMutableArray alloc] init];
    filteredMonthHolderArray = [[NSMutableArray alloc] init];
    finalMonthHolderArray = [[NSMutableArray alloc] init];
    finalTimeStampArray = [[NSMutableArray alloc] init];
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
        
        chosenObjectArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).chosenObjectArray;
        currentResultArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).currentResultArray;
        resultSetArray = ((AppDelegate *)[UIApplication sharedApplication].delegate).resultSetArray;
        resultForGraphs = ((AppDelegate *)[UIApplication sharedApplication].delegate).resultForGraphs;
        NSLog(@"app did recieve notification");
        
        [self setUpTheData];
        
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

- (void)setUpTheData{
    for (FLoutsideWrapper *outsideWrapper in resultSetArray) {
        NSMutableArray *timeStampArray = [[NSMutableArray alloc] init];
        NSMutableArray *finalValues = [[NSMutableArray alloc] init];
        NSMutableArray *filteredMonthArray = [[NSMutableArray alloc] init];
        NSMutableArray *finalMonthArray = [[NSMutableArray alloc] init];
        //NSLog(@"outsideWrapper %@", outsideWrapper);
        
        for (FLmainmodel *mainModel in outsideWrapper.value.timeSeries) {
            //if ([mainModel.variable.variableDescription isEqualToString:@"Discharge, cubic feet per second"]) {
            //NSLog(@"location %@", mainModel.sourceInfo.siteName);
            //[tableNameArray addObject:mainModel.sourceInfo.siteName];
            NSArray *valueHolder = mainModel.values;
            for (ValuesModel *tempHolderDictionary in valueHolder) {
                //NSString *finalValue = [tempHolderDictionary objectForKey:@"value"];
                NSArray *finalValue = tempHolderDictionary.value;
                tempdetail = tempHolderDictionary.value;
                
            }
            //            for (int i =0; 1<valueHolder.count; i++) {
            //                ValuesModel *holderValue = [valueHolder objectAtIndex:i];
            //                //NSDictionary *internalHolder = [holderDictionary objectForKey:@"value"];
            //                NSArray *finalValue = holderValue.value;
            //                NSLog(@"finalValue %@", finalValue);
            //            }
            //}
            
            
            
            
            for (ValueDetail *detailInstance in tempdetail) {
                
                //if (arrayBool) {
                    
                    if (innerArrayBool) {
                        //code
                        NSString *finalString = detailInstance.value;
                        NSLog(@"value %@", finalString);
                        [finalValues addObject:finalString];
                        NSString *dateTimeString = detailInstance.dateTime;
                        //NSLog(@"dateTime %@", finalValue);
                        [timeStampArray addObject:dateTimeString];
                        
                        NSString *testMonth = [dateTimeString substringWithRange:NSMakeRange(5, 2)];
                        NSString *testDay = [dateTimeString substringWithRange:NSMakeRange(8, 2)];
                        NSString *appendingHolder = [NSString stringWithFormat:@"%@%@",testMonth, testDay];
                        
                        [filteredMonthArray addObject:appendingHolder];
                        
//                        [filteredMonthHolderArray addObject:filteredMonthArray];
//                        [finalValuesHolderArray addObject:finalValues];
                        
                        innerArrayBool = NO;
                    }else{
                        innerArrayBool = YES;
                    }
                    
                    
                    //arrayBool = NO;
                //}else{
                //    arrayBool = YES;
                //}
                
                
                //[testDayArray addObject:testDay];
                
                
            }
            
            [filteredMonthHolderArray addObject:filteredMonthArray];
            [finalValuesHolderArray addObject:finalValues];
            [timeStampArray addObject:timeStampArray];
            
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:filteredMonthArray];
            NSSet *uniqueDates = [orderedSet set];
            NSLog(@"uniqueDates %@", uniqueDates);
            finalMonthArray = [NSMutableArray arrayWithArray:[uniqueDates allObjects]];
            [finalMonthHolderArray addObject:finalMonthArray];
        }
        
//
    }
    
    [self calcTheAverages];
    
}

- (void)calcTheAverages{
    
    //for (NSString *stringForGraphs in resultForGraphs) {
        for (int i=0; i<resultForGraphs.count; i++) {
            
            NSString *stringForGraphs = resultForGraphs[i];
            
            NSArray *components = [stringForGraphs componentsSeparatedByString:@"\n"];
            
            NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
            NSMutableArray *cleanedHolderArray = [[NSMutableArray alloc] init];
            NSMutableArray *objectHolderArray = [[NSMutableArray alloc] init];
            
            
            
            //NSLog(@"components %lu", (unsigned long)components.count);
            
            for (int i=0; i<workingDataArray.count; i++) {
                NSString *matchCriteria = @"USGS";
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
                
                //NSLog(@"object: %@", [workingDataArray objectAtIndex:i]);
                
                BOOL filePathMatches = [pred evaluateWithObject:[workingDataArray objectAtIndex:i]];
                //if (![[tableNameArray objectAtIndex:i] isEqualToString:@"YAMPA RIVER BELOW SODA CREEK AT STEAMBOAT SPGS, CO"]) {
                if (filePathMatches) {
                    NSArray *tempHolderArray = [[workingDataArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
                    
                    FLminMaxFlows *flowHolder = [[FLminMaxFlows alloc] init];
                    
                    flowHolder.agencyCd = [tempHolderArray objectAtIndex:0];
                    flowHolder.siteNum = [tempHolderArray objectAtIndex:1];
                    flowHolder.paramaterCd = [tempHolderArray objectAtIndex:2];
                    flowHolder.monthNu = [tempHolderArray objectAtIndex:4];
                    flowHolder.dayNu = [tempHolderArray objectAtIndex:5];
                    flowHolder.meanVa = [tempHolderArray objectAtIndex:13];
                    flowHolder.p25Va = [tempHolderArray objectAtIndex:17];
                    flowHolder.p75Va = [tempHolderArray objectAtIndex:19];
                    
                    [objectHolderArray addObject:flowHolder];
                    
                    flowHolder = nil;
                    
                    [cleanedHolderArray addObject:tempHolderArray];
                    //NSLog(@"cleanedHolderArray %lu", (unsigned long)cleanedHolderArray.count);
                    
                }
            }
            
            NSMutableArray *twentyFiveArray = [[NSMutableArray alloc] init];
            NSMutableArray *seventyFiveArray = [[NSMutableArray alloc] init];
            NSMutableArray *finalMonthArray = finalMonthHolderArray[i];
            
            for (NSString *tempMoDay in finalMonthArray) {
                NSString *internalMonthHolder = [tempMoDay substringWithRange:NSMakeRange(0, 2)];
                if ([internalMonthHolder hasPrefix:@"0"] && [internalMonthHolder length] > 1) {
                    internalMonthHolder = [internalMonthHolder substringFromIndex:1];
                }
                NSString *internalDayHolder = [tempMoDay substringWithRange:NSMakeRange(2, 2)];
                if ([internalDayHolder hasPrefix:@"0"] && [internalDayHolder length] > 1) {
                    internalDayHolder = [internalDayHolder substringFromIndex:1];
                }
                
                for (FLminMaxFlows *temp in objectHolderArray) {
                    
                    if ([temp.monthNu isEqualToString:internalMonthHolder]) {
                        if ([temp.dayNu isEqualToString:internalDayHolder]) {
                            //[meanArray addObject:temp.meanVa];
                            [twentyFiveArray addObject:temp.p25Va];
                            [seventyFiveArray addObject:temp.p75Va];
                        }
                    }
                    
                    
                }
                
                
            }
            
            
            [twentyFiveHolderArray addObject:twentyFiveArray];
            [seventyFiveHolderArray addObject:seventyFiveArray];
            
        }
        

    //}
    //[self setUpTheData];
    if (refreshControl) {
        [refreshControl endRefreshing];
    }
    [indicatorView stopAnimating];
    _mainTable.hidden = NO;
    [_mainTable reloadData];
    
    
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
        [chosenObjectArray removeObjectAtIndex:indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:chosenObjectArray forKey:@"chosenObjects"];
        [defaults synchronize];
        [currentResultArray removeObjectAtIndex:indexPath.row];
        [resultSetArray removeObjectAtIndex:indexPath.row];
        [resultForGraphs removeObjectAtIndex:indexPath.row];
        //[[[UIApplication sharedApplication] delegate] performSelector:@selector(currentStationData)];
        //[indicatorView startAnimating];
        [_mainTable reloadData];
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
            NSMutableArray *twentyFiveCell = [twentyFiveHolderArray objectAtIndex:indexPath.row];
            NSMutableArray *seventyFiveCell = [seventyFiveHolderArray objectAtIndex:indexPath.row];
            int siteValue = (int)[[innerDictionary objectForKey:@"siteValue"] integerValue];
            int twentyFive = (int)[[twentyFiveCell lastObject] integerValue];
            int seventyFive = (int)[[seventyFiveCell lastObject] integerValue];
            if (siteValue < twentyFive) {
                cell.resultLabel.textColor = [UIColor colorWithRed:6/255.0f green:119/255.0f blue:236/255.0f alpha:1.0f];
            }else if (siteValue > seventyFive){
                cell.resultLabel.textColor = [UIColor colorWithRed:234/255.0f green:105/255.0f blue:71/255.0f alpha:1.0f];
            }else{
                cell.resultLabel.textColor = [UIColor colorWithRed:111/255.0f green:229/255.0f blue:125/255.0f alpha:1.0f];
            }
            
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSDictionary *cellDict = [chosenObjectsArray objectAtIndex:indexPath.row];
    //pull detail data here!!!
    //FLoutsideWrapper *wrapperToPass = [resultSetArray objectAtIndex:indexPath.row];
    //NSString *resultForGraphString = [resultForGraphs objectAtIndex:indexPath.row];
    NSDictionary *dictionaryForCell = [chosenObjectArray objectAtIndex:indexPath.row];
    NSString *titleToPass = [dictionaryForCell objectForKey:@"siteName"];
    NSString *locationToPass = [dictionaryForCell objectForKey:@"siteLocation"];
    NSMutableArray *twentyFiveValues = [twentyFiveHolderArray objectAtIndex:indexPath.row];
    NSMutableArray *seventyFiveValues = [seventyFiveHolderArray objectAtIndex:indexPath.row];
    NSMutableArray *finalValues = [finalValuesHolderArray objectAtIndex:indexPath.row];
    //NSMutableArray *finalTimeStamp = [finalTimeStampArray objectAtIndex:indexPath.row];
    
    [self.sidePanelController showRightPanelAnimated:YES];
    
    NSDictionary *theInfo =
    [NSDictionary dictionaryWithObjectsAndKeys:titleToPass, @"titleToPass", locationToPass, @"locationToPass", twentyFiveValues, @"twentyFiveValues", seventyFiveValues, @"seventyFiveValues", finalValues, @"finalValues", nil];
    
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unlimted Stations"
                                                        message:@"text texte texte txetex textexte txe text exte txetx etxex"
                                                       delegate:self
                                              cancelButtonTitle:@"no thanks"
                                              otherButtonTitles:@"Buy!", nil];
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
