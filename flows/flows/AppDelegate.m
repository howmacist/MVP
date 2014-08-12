//
//  AppDelegate.m
//  flows
//
//  Created by Matt Riddoch on 7/9/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "AppDelegate.h"
#import "FLminMaxFlows.h"
#import "FLmainmodel.h"
#import "FLoutsideWrapper.h"
#import "flowsIAPHelper.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define KMainQueue dispatch_get_main_queue()

@implementation AppDelegate{
    NSUserDefaults *defaults;
    FLoutsideWrapper* _outsideWrapper;
    NSMutableArray *timeStampArray;
    NSArray<ValueDetail>* tempdetail;
    BOOL arrayBool;
    BOOL innerArrayBool;
    NSMutableArray *filteredMonthArray;
    int dataTracker;
}

@synthesize chosenObjectArray;
@synthesize currentResultArray;
@synthesize resultSetArray;
@synthesize resultForGraphs;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    defaults = [NSUserDefaults standardUserDefaults];
    chosenObjectArray = [[NSMutableArray alloc] init];
    currentResultArray = [[NSMutableArray alloc] init];
    filteredMonthArray = [[NSMutableArray alloc] init];
    resultSetArray = [[NSMutableArray alloc] init];
    resultForGraphs = [[NSMutableArray alloc] init];
    dataTracker = 0;
    chosenObjectArray = [[defaults objectForKey:@"chosenObjects"] mutableCopy];
    if (chosenObjectArray.count > 0) {
        [self currentStationData];
    }
    [flowsIAPHelper sharedInstance];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark data pull methods

-(void)currentStationData{
    chosenObjectArray = [[defaults objectForKey:@"chosenObjects"] mutableCopy];
    [resultSetArray removeAllObjects];
    NSString *siteHolderString;
    for (int i = 0; i < chosenObjectArray.count; i++) {
        NSDictionary *dictAtIndex = [chosenObjectArray objectAtIndex:i];
        if (i == 0) {
            siteHolderString = [dictAtIndex objectForKey:@"siteNumber"];
            //}else if (i > 0 && 1 < chosenObjectsArray.count){
        }else{
            siteHolderString = [NSString stringWithFormat:@"%@,%@", siteHolderString, [dictAtIndex objectForKey:@"siteNumber"]];
        }
    }
    
    NSString *requestString = [NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=rdb&sites=%@&parameterCd=00060", siteHolderString];
    
    
    
    
    //dispatch_async(kBgQueue, ^{
    dispatch_async(KMainQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:requestString]];
        [self performSelectorOnMainThread:@selector(currentDataPull:)
                               withObject:data waitUntilDone:YES];
        
    });
    
    for (NSDictionary *chosenDict in chosenObjectArray) {
        
        NSString *flowsting = [NSString stringWithFormat:@"http://waterdata.usgs.gov/nwis/dvstat/?site_no=%@&format=rdb&submitted_form=parameter_selection_list&PARAmeter_cd=00060", [chosenDict objectForKey:@"siteNumber"]];
        
        
        //dispatch_async(kBgQueue, ^{
        dispatch_async(KMainQueue, ^{
            NSData* flowData = [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:flowsting]];
            [self performSelectorOnMainThread:@selector(fetchedFlowData:)
                                   withObject:flowData waitUntilDone:YES];
            //NSLog(@"flowData %@", flowData);
            
        });
        
#pragma mark - TODO check extra call
        
            NSString *finalString = [NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=json&sites=%@&period=P3D&parameterCd=00060", [chosenDict objectForKey:@"siteNumber"]];
            NSURL *urlToPass = [NSURL URLWithString:finalString];
            
            //dispatch_async(kBgQueue, ^{
            dispatch_async(KMainQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:
                                urlToPass];
                [self performSelectorOnMainThread:@selector(fetchedData:)
                                       withObject:data waitUntilDone:YES];
            });
        
    }
    
    NSLog(@"test finished");
    
}

- (void)currentDataPull:(NSData *)responseData{
    
    NSString *responseHolder = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    
    NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
    
    for (int i=0; i<workingDataArray.count; i++) {
        NSString *matchCriteria = @"USGS";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
        BOOL filePathMatches = [pred evaluateWithObject:[workingDataArray objectAtIndex:i]];
        
        if (filePathMatches) {
            NSArray *tempHolderArray = [[workingDataArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
            //NSLog(@"object: %@", tempHolderArray);
            NSDictionary *tempHolder = [[NSDictionary alloc] initWithObjectsAndKeys:[tempHolderArray objectAtIndex:1], @"siteNumber", [tempHolderArray objectAtIndex:4], @"siteValue", nil];
            [currentResultArray addObject:tempHolder];
        }
        
    }
    
    //[dashTable reloadData];
    
}


#pragma mark - min max data pull

- (void)fetchedFlowData:(NSData *)responseData{
    NSString *responseHolder = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    [resultForGraphs addObject:responseHolder];
        NSLog(@"test");
    
}


- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    _outsideWrapper = [[FLoutsideWrapper alloc] initWithDictionary:json error:nil];
    [resultSetArray addObject:_outsideWrapper];
    [self handleTheData];
    
}

-(void)handleTheData {
    
    
    NSLog(@"End of data");
    if (dataTracker < chosenObjectArray.count-1) {
        dataTracker += 1;
    }else{
        dataTracker = 0;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"didLoadOne"
         object:nil];
    }
    
    
}



@end
