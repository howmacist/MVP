//
//  addInstanceViewController.m
//  flows
//
//  Created by Matt Riddoch on 7/26/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "addInstanceViewController.h"
#import "GDIIndexBar.h"
#import "TYMActivityIndicatorView.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface addInstanceViewController () <UITableViewDelegate, UITableViewDataSource, GDIIndexBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) TYMActivityIndicatorView *activityIndicatorView1;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;


@end

@implementation addInstanceViewController{
    NSMutableArray *stateHolder;
    NSMutableArray *queryHolder;
    NSMutableArray *siteNumberHolder;
    NSMutableArray *sitNameHolder;
    NSMutableArray *sortedArray;
    NSMutableArray *splitHolder;
    NSMutableArray *splitNameHolder;
    NSMutableArray *splitLocationHolder;
    
    NSMutableDictionary *siteHolderDict;
    
    NSMutableArray *dictionaryArray;
    
    BOOL isInState;
    NSString *idToPass;
    
    NSMutableArray *usersNameOneArray;
    NSMutableArray *usersNameTwoArray;
    NSMutableArray *usersIDArray;
    
    NSMutableArray *alphabetsArray;
    NSMutableArray *riverAlphabetsArray;
    
    NSMutableArray *riverDetailArray;
    
    NSMutableArray *sortedDetailForTable;
    
    
    NSArray *dictionariesForSort;
    NSMutableArray *finishedDictionaries;
    
    GDIIndexBar *indexBar;
    
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
    [self setNeedsStatusBarAppearanceUpdate];
    stateHolder = [[NSMutableArray alloc] initWithObjects:@"Alabama", @"Alaska", @"American Samoa", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Dist. of Columbia", @"Florida", @"Georgia", @"Guam", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Northern Mariana Islands", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Puerto Rico", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virgin Islands", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil];
    queryHolder = [[NSMutableArray alloc] initWithObjects:@"al", @"ak", @"aq", @"az", @"ar", @"ca", @"co", @"ct", @"de", @"dc", @"fl", @"ga", @"gu", @"hi", @"id", @"il", @"in", @"ia", @"ks", @"ky", @"la", @"me", @"md", @"ma", @"mi", @"mn", @"ms", @"mo", @"mt", @"ne", @"nv", @"nh", @"nj", @"nm", @"ny", @"nc", @"nd", @"mp", @"oh", @"ok", @"or", @"pa", @"pr", @"ri", @"sc", @"sd", @"tn", @"tx", @"ut", @"vt", @"vi", @"va", @"wa", @"wv", @"wi", @"wy", nil];
    siteNumberHolder = [[NSMutableArray alloc] init];
    sitNameHolder = [[NSMutableArray alloc] init];
    sortedArray = [[NSMutableArray alloc] init];
    splitHolder = [[NSMutableArray alloc] init];
    siteHolderDict = [[NSMutableDictionary alloc] init];
    dictionaryArray = [[NSMutableArray alloc] init];
    
    dictionariesForSort = [[NSArray alloc] init];
    
    riverAlphabetsArray = [[NSMutableArray alloc] init];
    alphabetsArray = [[NSMutableArray alloc] init];
    
    splitNameHolder = [[NSMutableArray alloc] init];
    splitLocationHolder = [[NSMutableArray alloc] init];
    
    sortedDetailForTable = [[NSMutableArray alloc] init];
    
    finishedDictionaries = [[NSMutableArray alloc] init];
    
    [self createAlphabetArray];
    
    isInState = YES;
    
    usersNameOneArray = [[NSMutableArray alloc] init];
    usersNameTwoArray = [[NSMutableArray alloc] init];
    usersIDArray = [[NSMutableArray alloc] init];
    
    riverDetailArray = [[NSMutableArray alloc] init];
    
    _backButton.hidden = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempOne = [[defaults objectForKey:@"riverNameArray"] mutableCopy];
    if (tempOne.count > 0) {
        usersNameOneArray = tempOne;
    }
    NSMutableArray *tempTwo = [[defaults objectForKey:@"riverLocationArray"] mutableCopy];
    if (tempTwo.count > 0) {
        usersNameTwoArray = tempTwo;
    }
    NSMutableArray *tempID = [[defaults objectForKey:@"riverIDArray"] mutableCopy];
    if (tempID.count > 0) {
        usersIDArray = tempID;
    }
    
    indexBar = [[GDIIndexBar alloc] initWithTableView:_mainTable];
    [[GDIIndexBar appearance] setTextColor:[UIColor whiteColor]];
    [[GDIIndexBar appearance] setBarBackgroundColor:[UIColor clearColor]];
    indexBar.delegate = self;
    [self.view addSubview:indexBar];
    if (!_activityIndicatorView1) {
        _activityIndicatorView1 = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleLarge];
        _activityIndicatorView1.hidesWhenStopped = YES;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - tableviewdelegates

#pragma mark - tableviewdelegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isInState) {
        return alphabetsArray.count;
    }else{
        return riverAlphabetsArray.count;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isInState) {
        
        //return stateHolder.count;
        NSArray *sectionArray = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:section]]];
        return sectionArray.count;
        
    }else{
        NSLog(@"section %lu", (long)section);
        NSArray *sectionArray = [sortedDetailForTable filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [riverAlphabetsArray objectAtIndex:section]]];
        return sectionArray.count;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (isInState) {
        return nil;
    }else{
        return [riverAlphabetsArray objectAtIndex:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor blackColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isInState) {
        return 0;
    }else{
        return 35;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addCell";
    
    
    
    //FLintroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (isInState) {
        
        NSArray *sectionArray = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
        NSLog(@"section for row state %lu", (long)indexPath.section);
        cell.textLabel.text = [sectionArray objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = nil;
        
        
        [cell setBackgroundColor:[UIColor clearColor]];
        //UIImage *backgroundImage = nil;
        UIImageView *backgroundView = nil;
        //backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"YourYellowCellImage"ofType:@"png"]];
        //backgroundView = [[UIImageView alloc]initWithImage:backgroundImage];
        backgroundView.frame = CGRectMake(0, 0, 320, 44); // Over here give your cell size
        //cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backgroundView;
        
        
    }else{
        
        //[sortedDetailForTable removeAllObjects];
        //NSArray *presortDetailForTable = [[NSArray alloc] init];
        NSString *stringForFilter = [riverAlphabetsArray objectAtIndex:indexPath.section];
        NSLog(@"section for row %lu", (long)indexPath.section);
        
        
        
        
        //presortDetailForTable = [[tempHolder objectAtIndex:0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", stringForFilter]];
        //NSLog(@"presortDetailForTable %@", presortDetailForTable);
        //[splitHolder removeAllObjects];
        //[self splitObjectsFromArray:presortDetailForTable];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.siteName BEGINSWITH[cd] %@",stringForFilter];
        
        
        //NSMutableArray *sectionArray = [NSMutableArray arrayWithArray:[riverDetailArray filteredArrayUsingPredicate:predicate]];
        NSMutableArray *sectionArray = [NSMutableArray arrayWithArray:[finishedDictionaries filteredArrayUsingPredicate:predicate]];
        //NSArray *testArray = [NSArray arrayWithArray:[riverDetailArray filteredArrayUsingPredicate:predicate]];
        
        //sort here...
        
        //splitHolder = sectionArray;
        //NSLog(@"testArray %@", testArray);
        
        
        
        
        //cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];
        //NSArray *tempHolderArray = [splitHolder objectAtIndex:indexPath.row];
        //cell.textLabel.text = [tempHolderArray objectAtIndex:0];
        NSDictionary *testTitle = [sectionArray objectAtIndex:indexPath.row];
        NSString *testOneHolder = [testTitle objectForKey:@"siteName"];
        cell.textLabel.text = testOneHolder;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = [testTitle objectForKey:@"siteLocation"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        [cell setBackgroundColor:[UIColor clearColor]];
        //UIImage *backgroundImage = nil;
        UIImageView *backgroundView = nil;
        //backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"YourYellowCellImage"ofType:@"png"]];
        //backgroundView = [[UIImageView alloc]initWithImage:backgroundImage];
        backgroundView.frame = CGRectMake(0, 0, 320, 44); // Over here give your cell size
        //cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backgroundView;
        
        
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (isInState) {
        
        NSArray *sectionArray = [queryHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
        NSArray *tempStateHolder = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
        //stateLabel.text = [tempStateHolder objectAtIndex:indexPath.row];
        
        [self.view addSubview:self.activityIndicatorView1];
        [self.activityIndicatorView1 startAnimating];
        
        NSString *tempValueHolder = [sectionArray objectAtIndex:indexPath.row];
        NSString *stateResultString = [NSString stringWithFormat:@"http://waterdata.usgs.gov/nwis/current?state_cd=%@&index_pmcode_STATION_NM=1&index_pmcode_DATETIME=2&index_pmcode_00060=3&group_key=NONE&format=sitefile_output&sitefile_output_format=rdb&column_name=agency_cd&column_name=site_no&column_name=station_nm&sort_key_2=site_no&html_table_group_key=NONE&rdb_compression=file&list_of_search_criteria=state_cd%%2Crealtime_parameter_selection", tempValueHolder];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:stateResultString]];
            [self performSelectorOnMainThread:@selector(stateData:)
                                   withObject:data waitUntilDone:YES];
            
        });
        
        _backButton.hidden = NO;
        
        
    }else{
        
        
        
        NSString *stringForFilter = [riverAlphabetsArray objectAtIndex:indexPath.section];
        
        // orig code
        //        NSArray *tempHolderArray = [splitHolder objectAtIndex:indexPath.row];
        //        NSString *holderOne = [tempHolderArray objectAtIndex:0];
        //        NSString *holderTwo = [NSString stringWithFormat:@" %@", [tempHolderArray objectAtIndex:1]];
        //        NSString *originalString = [holderOne stringByAppendingString:holderTwo];
        //[mainTable reloadData];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.siteName BEGINSWITH[cd] %@",stringForFilter];
        
        
        //NSMutableArray *sectionArray = [NSMutableArray arrayWithArray:[riverDetailArray filteredArrayUsingPredicate:predicate]];
        NSMutableArray *sectionArray = [NSMutableArray arrayWithArray:[finishedDictionaries filteredArrayUsingPredicate:predicate]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *chosenObjects = [[defaults objectForKey:@"chosenObjects"] mutableCopy];
        //        usersNameTwoArray = [[defaults objectForKey:@"usersNameTwoArray"] mutableCopy];
        //        usersIDArray = [[defaults objectForKey:@"usersIDArray"] mutableCopy];
        
        if (chosenObjects.count < 1) {
            chosenObjects = [[NSMutableArray alloc] init];
        }
        
//        if (chosenObjects.count == 5 && !isPurchased) {
//            //code
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Row Limit"
//                                                            message:@"To use more then 5 locations purchase an upgrade. Slide rows on the main table to delete current instances."
//                                                           delegate:self
//                                                  cancelButtonTitle:@"No Thanks"
//                                                  otherButtonTitles:@"Purchase", nil];
//            [alert show];
//        }
        
        NSDictionary *chosenDict = [sectionArray objectAtIndex:indexPath.row];
        
        [chosenObjects addObject:chosenDict];
        
        [defaults setObject:chosenObjects forKey:@"chosenObjects"];
        
        [defaults synchronize];
        
        NSLog(@"chosenDict %@", chosenDict);
        
        
        //        NSMutableArray *tempNameHolderArray = [[NSMutableArray alloc] init];
        //        for (NSArray *tempHolder in splitHolder) {
        //            NSString *compstring = [NSString stringWithFormat:@"%@ %@", [tempHolder objectAtIndex:0], [tempHolder objectAtIndex:1]];
        //            [tempNameHolderArray addObject:compstring];
        //        }
        //
        //
        //
        //        for (int i = 0; i < tempNameHolderArray.count; i++) {
        //            if ([originalString isEqualToString:[tempNameHolderArray objectAtIndex:i]]) {
        //                idToPass = [siteNumberHolder objectAtIndex:i];
        //                NSLog(@"testing");
        //
        //
        //
        //                [usersNameOneArray addObject:holderOne];
        //                [usersNameTwoArray addObject:[tempHolderArray objectAtIndex:1]];
        //                [usersIDArray addObject:idToPass];
        //                [defaults setObject:usersNameOneArray forKey:@"riverNameArray"];
        //                [defaults setObject:usersNameTwoArray forKey:@"riverLocationArray"];
        //                [defaults setObject:usersIDArray forKey:@"riverIDArray"];
        //                [defaults synchronize];
        //                //[self performSegueWithIdentifier:@"detailPush" sender:self];
        //                isInState = YES;
        //                break;
        //                
        //            }
        //        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}



#pragma mark - IBAction

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchClicked:(id)sender {
}

#pragma mark - TODO old code

#pragma mark - Create Alphabet Array
- (void)createAlphabetArray {
    [alphabetsArray removeAllObjects];
    //NSMutableArray *tempFirstLetterArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [stateHolder count]; i++) {
        NSString *letterString = [[stateHolder objectAtIndex:i] substringToIndex:1];
        if (![alphabetsArray containsObject:letterString]) {
            [alphabetsArray addObject:letterString];
        }
    }
    //alphabetsArray = tempFirstLetterArray;
    
}

- (void)createRiverNameArray {
    
    [riverAlphabetsArray removeAllObjects];
    [riverDetailArray removeAllObjects];
    
    
    for (NSDictionary *rivDict in finishedDictionaries) {
        NSString *stringForSubstring = [rivDict objectForKey:@"siteName"];
        NSString *letterString = [stringForSubstring substringToIndex:1];
        if (![riverAlphabetsArray containsObject:letterString]) {
            [riverAlphabetsArray addObject:letterString];
        }
    }
    
    
    // old code
    //    for (int i = 0; i < splitHolder.count; i++) {
    //        NSArray *holderarray = [splitHolder objectAtIndex:i];
    //        NSString *firstObject = [holderarray objectAtIndex:0];
    //        NSString *forSubstringObject = [splitHolder objectAtIndex:i];
    //        NSString *secondObject = [holderarray objectAtIndex:1];
    //        NSDictionary *riverdictionary = [[NSDictionary alloc] initWithObjectsAndKeys:firstObject, @"riverName", secondObject, @"riverLocation", nil];
    //        //addObject.riverName = firstObject;
    //        //addObject.riverLocation = secondObject;
    //        [riverDetailArray addObject:riverdictionary];
    //        NSString *letterString = [firstObject substringToIndex:1];
    //        if (![riverAlphabetsArray containsObject:letterString]) {
    //            [riverAlphabetsArray addObject:letterString];
    //        }
    //    }
    //
    //    NSLog(@"riverDetailArray %@", riverDetailArray);
    //    //[self splitObjectsFromArray:sortedArray];
}


- (void)createRiverObject{
    [riverDetailArray removeAllObjects];
    
    for (NSArray *holderArray in splitHolder) {
        //addRiverObject *addObject = [[addRiverObject alloc] init];
        NSString *one = [holderArray objectAtIndex:0];
        NSString *two = [holderArray objectAtIndex:1];
        NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:one, @"riverName", two, @"riverLocation", nil];
        
        //addObject.riverName = [holderArray objectAtIndex:0];
        //addObject.riverLocation = [holderArray objectAtIndex:1];
        [riverDetailArray addObject:objectDictionary];
    }
    
    
}


- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    if (isInState) {
        return alphabetsArray.count;
    }else{
        return riverAlphabetsArray.count;
        
    }
    
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    if (isInState) {
        return [alphabetsArray objectAtIndex:index];
    }else{
        return [riverAlphabetsArray objectAtIndex:index];
    }
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    [_mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:NO];
}


-(void)stateData:(NSData *)responseData{
    NSString *responseHolder = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    
    NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
    //NSMutableArray *cleanedHolderArray = [[NSMutableArray alloc] init];
    //NSMutableArray *objectHolderArray = [[NSMutableArray alloc] init];
    
    
    
    //NSLog(@"components %lu", (unsigned long)components.count);
    
    NSMutableArray *tempForSort = [[NSMutableArray alloc] init];
    
    for (int i=0; i<workingDataArray.count; i++) {
        NSString *matchCriteria = @"USGS";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
        
        
        
        BOOL filePathMatches = [pred evaluateWithObject:[workingDataArray objectAtIndex:i]];
        //if (![[tableNameArray objectAtIndex:i] isEqualToString:@"YAMPA RIVER BELOW SODA CREEK AT STEAMBOAT SPGS, CO"]) {
        if (filePathMatches) {
            NSArray *tempHolderArray = [[workingDataArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
            //NSLog(@"object: %@", tempHolderArray);
            [siteNumberHolder addObject:[tempHolderArray objectAtIndex:1]];
            [sitNameHolder addObject:[tempHolderArray objectAtIndex:2]];
            [sortedArray addObject:[tempHolderArray objectAtIndex:2]];
            NSDictionary *tempInstanceDict = [[NSDictionary alloc] initWithObjectsAndKeys:[tempHolderArray objectAtIndex:1], @"siteNumber", [tempHolderArray objectAtIndex:2], @"siteName", nil];
            [tempForSort addObject:tempInstanceDict];
        }
        
        //[siteHolderDict setObject:siteNumberHolder forKey:@"siteNumber"];
        //[siteHolderDict setObject:sitNameHolder forKey:@"siteName"];
        
        
        
        [sortedArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        //[self splitObjectsFromArray:sortedArray];
        
    }
    
    NSSortDescriptor *siteDescriptor = [[NSSortDescriptor alloc] initWithKey:@"siteName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:siteDescriptor];
    dictionariesForSort = [tempForSort sortedArrayUsingDescriptors:sortDescriptors];
    
    [self splitObjectsFromArray:sortedArray];
    
    [self createRiverNameArray];
    
    
    //NSLog(@"splitHolder %@", splitHolder);
    isInState = NO;
    
    [_mainTable reloadData];
    [indexBar reload];
    [self.activityIndicatorView1 stopAnimating];
    
    //[mainTable reloadData];
}

-(void)splitObjectsFromArray:(NSArray*)incomingArray{
    
    [splitHolder removeAllObjects];
    [sortedDetailForTable removeAllObjects];
    [finishedDictionaries removeAllObjects];
    
    
    for (int i = 0; i < incomingArray.count; i++) {
        NSString *outsideRiverCriteria = @" RIVER ";
        NSString *outsideRiverTwoCriteria = @" R ";
        NSString *outsideTunnelCriteria = @" TUNNEL ";
        NSString *outsideCreekCriteria = @" CREEK ";
        NSString *outsideCreekTwoCriteria = @" CR ";
        NSString *outsideCreekThreeCriteria = @" C ";
        NSString *outsideGulchCriteria = @" GULCH ";
        NSString *outsideArroyoCriteria = @" ARROYO ";
        NSString *outsideForkCriteria = @" FORK ";
        NSString *outsideWashCriteria = @" WASH ";
        
        NSPredicate *outsideRiverPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideRiverCriteria];
        NSPredicate *outsideRiverTwoPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideRiverTwoCriteria];
        NSPredicate *outsideTunnelPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideTunnelCriteria];
        NSPredicate *outsideCreekPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideCreekCriteria];
        NSPredicate *outsideCreekTwoPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideCreekTwoCriteria];
        NSPredicate *outsideCreekThreePred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideCreekThreeCriteria];
        NSPredicate *outsideGulchPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideGulchCriteria];
        NSPredicate *outsideAroyoPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideArroyoCriteria];
        NSPredicate *outsideForkPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideForkCriteria];
        NSPredicate *outsideWashPred = [NSPredicate predicateWithFormat:@"self CONTAINS %@", outsideWashCriteria];
        
        NSDictionary *objectAtIndexDict = [dictionariesForSort objectAtIndex:i];
        
        //        BOOL outsideRiverMatches = [outsideRiverPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideRiverTwoMatches = [outsideRiverTwoPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideTunnelMatches = [outsideTunnelPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideCreekMatches = [outsideCreekPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideCreekTwoMatches = [outsideCreekTwoPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideCreekThreeMatches = [outsideCreekThreePred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideGulchMatches = [outsideGulchPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideArroyoMatches = [outsideAroyoPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideForkMatches = [outsideForkPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        //        BOOL outsideWashMatches = [outsideWashPred evaluateWithObject:[sortedArray objectAtIndex:i]];
        
        BOOL outsideRiverMatches = [outsideRiverPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideRiverTwoMatches = [outsideRiverTwoPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideTunnelMatches = [outsideTunnelPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideCreekMatches = [outsideCreekPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideCreekTwoMatches = [outsideCreekTwoPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideCreekThreeMatches = [outsideCreekThreePred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideGulchMatches = [outsideGulchPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideArroyoMatches = [outsideAroyoPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideForkMatches = [outsideForkPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        BOOL outsideWashMatches = [outsideWashPred evaluateWithObject:[objectAtIndexDict objectForKey:@"siteName"]];
        
        NSMutableArray *finalHolder = [[NSMutableArray alloc] init];
        
        //if (![[tableNameArray objectAtIndex:i] isEqualToString:@"YAMPA RIVER BELOW SODA CREEK AT STEAMBOAT SPGS, CO"]) {
        if (outsideRiverMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" RIVER "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" RIVER"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideRiverTwoMatches = NO;
            outsideTunnelMatches = NO;
            outsideCreekMatches = NO;
            outsideCreekTwoMatches = NO;
            outsideCreekThreeMatches = NO;
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideRiverTwoMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" R "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" R"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideTunnelMatches = NO;
            outsideCreekMatches = NO;
            outsideCreekTwoMatches = NO;
            outsideCreekThreeMatches = NO;
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideTunnelMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" TUNNEL "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" TUNNEL"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideCreekMatches = NO;
            outsideCreekTwoMatches = NO;
            outsideCreekThreeMatches = NO;
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideCreekMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" CREEK "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            if (myWords.count == 3) {
                NSString *extraString = [myWords objectAtIndex:2];
                locationHolder = [locationHolder stringByAppendingString:@" CREEK "];
                locationHolder = [locationHolder stringByAppendingString:extraString];
            }
            nameHolder = [nameHolder stringByAppendingString:@" CREEK"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideCreekTwoMatches = NO;
            outsideCreekThreeMatches = NO;
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideCreekTwoMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" CR "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" CR"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideCreekThreeMatches = NO;
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideCreekThreeMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" C "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" C"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideGulchMatches = NO;
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideGulchMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" GULCH "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" GULCH"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideArroyoMatches = NO;
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideArroyoMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" ARROYO "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" ARROYO"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideForkMatches = NO;
            outsideWashMatches = NO;
        }
        if (outsideForkMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" FORK "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" FORK"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
            outsideWashMatches = NO;
        }
        if (outsideWashMatches) {
            [finalHolder removeAllObjects];
            
            NSDictionary *innerDict = [dictionariesForSort objectAtIndex:i];
            NSString *tempNumberHolder = [innerDict objectForKey:@"siteNumber"];
            NSArray *myWords = [[innerDict objectForKey:@"siteName"] componentsSeparatedByString:@" WASH "];
            NSString *nameHolder = [myWords objectAtIndex:0];
            NSString *locationHolder = [myWords objectAtIndex:1];
            nameHolder = [nameHolder stringByAppendingString:@" WASH"];
            [finalHolder addObject:nameHolder];
            [finalHolder addObject:locationHolder];
            NSDictionary *dictForFinal = [[NSDictionary alloc] initWithObjectsAndKeys:nameHolder, @"siteName", locationHolder, @"siteLocation", tempNumberHolder, @"siteNumber", nil];
            [finishedDictionaries addObject:dictForFinal];
            [splitHolder addObject:finalHolder];
            [sortedDetailForTable addObject:nameHolder];
        }
        
        
    }
    
    
}




@end
