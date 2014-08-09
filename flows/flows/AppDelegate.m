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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define KMainQueue dispatch_get_main_queue()

@implementation AppDelegate{
    //NSMutableArray *chosenObjectsArray;
    //NSMutableArray *currentResultArray;
    NSUserDefaults *defaults;
    NSMutableArray *finalMonthArray;
    NSMutableArray *meanArray;
    NSMutableArray *twentyFiveArray;
    NSMutableArray *seventyFiveArray;
    NSMutableArray *finalValues;
    NSNumber* minForGraphs;
    NSNumber* maxForGraphs;
    NSNumber* meanForGraphs;
    FLoutsideWrapper* _outsideWrapper;
    NSMutableArray *timeStampArray;
    NSArray<ValueDetail>* tempdetail;
    BOOL arrayBool;
    BOOL innerArrayBool;
    NSMutableArray *filteredMonthArray;
}

@synthesize chosenObjectArray;
@synthesize currentResultArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    defaults = [NSUserDefaults standardUserDefaults];
    chosenObjectArray = [[NSMutableArray alloc] init];
    currentResultArray = [[NSMutableArray alloc] init];
    finalMonthArray = [[NSMutableArray alloc] init];
    meanArray = [[NSMutableArray alloc] init];
    twentyFiveArray = [[NSMutableArray alloc] init];
    seventyFiveArray = [[NSMutableArray alloc] init];
    finalValues = [[NSMutableArray alloc] init];
    filteredMonthArray = [[NSMutableArray alloc] init];
    chosenObjectArray = [[defaults objectForKey:@"chosenObjects"] mutableCopy];
    if (chosenObjectArray.count > 0) {
        [self currentStationData];
    }
    
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
        
        
        for (NSDictionary *current in chosenObjectArray) {
            NSString *finalString = [NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=json&sites=%@&period=P3D&parameterCd=00060", [current objectForKey:@"siteNumber"]];
            NSURL *urlToPass = [NSURL URLWithString:finalString];
            
            //dispatch_async(kBgQueue, ^{
            dispatch_async(KMainQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:
                                urlToPass];
                [self performSelectorOnMainThread:@selector(fetchedData:)
                                       withObject:data waitUntilDone:YES];
            });
        }
        
        
        //flowData = [NSURL URLWithString:flowsting];
        
    }
    
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
    //NSLog(@"responseHolder %@", responseHolder);
    
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    
    NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
    NSMutableArray *cleanedHolderArray = [[NSMutableArray alloc] init];
    NSMutableArray *objectHolderArray = [[NSMutableArray alloc] init];
    
    
    
    //NSLog(@"components %lu", (unsigned long)components.count);
    
    for (int i=0; i<workingDataArray.count; i++) {
        NSString *matchCriteria = @"USGS";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
        
        NSLog(@"object: %@", [workingDataArray objectAtIndex:i]);
        
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
                    [meanArray addObject:temp.meanVa];
                    [twentyFiveArray addObject:temp.p25Va];
                    [seventyFiveArray addObject:temp.p75Va];
                }
            }
            
            
        }
        
        
    }
    

    
    
    
    float finalXmax = -MAXFLOAT;
    float finalXmin = MAXFLOAT;
    for (NSNumber *num in finalValues) {
        float x = num.floatValue;
        if (x < finalXmin) finalXmin = x;
        if (x > finalXmax) finalXmax = x;
    }
    
    float twentyXmax = -MAXFLOAT;
    float twentyXmin = MAXFLOAT;
    for (NSNumber *num in twentyFiveArray) {
        float x = num.floatValue;
        if (x < twentyXmin) twentyXmin = x;
        if (x > twentyXmax) twentyXmax = x;
    }
    
    float seventyXmax = -MAXFLOAT;
    float seventyXmin = MAXFLOAT;
    for (NSNumber *num in seventyFiveArray) {
        float x = num.floatValue;
        if (x < seventyXmin) seventyXmin = x;
        if (x > seventyXmax) seventyXmax = x;
    }
    
    float tempMinHolder;
    float tempMeanHolder;
    float tempMaxHolder;
    
    
    if (twentyXmin < finalXmin) {
        minForGraphs = [NSNumber numberWithFloat:twentyXmin];
        tempMinHolder = twentyXmin;
    }else{
        minForGraphs = [NSNumber numberWithFloat:finalXmin];
        tempMinHolder = finalXmin;
    }
    
    if (seventyXmax > finalXmax) {
        maxForGraphs = [NSNumber numberWithFloat:seventyXmax];
        tempMaxHolder = seventyXmax;
    }else{
        maxForGraphs = [NSNumber numberWithFloat:finalXmax];
        tempMaxHolder = finalXmax;
    }
    
    tempMeanHolder = tempMaxHolder - tempMinHolder;
    meanForGraphs = [NSNumber numberWithFloat:tempMeanHolder / 2];
    
    NSLog(@"test");
    
    //[self populateMeanGraph];
    
}


- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    _outsideWrapper = [[FLoutsideWrapper alloc] initWithDictionary:json error:nil];
    
    [self handleTheData];
    
}

-(void)handleTheData {
    
    //    tableNameArray= [[NSMutableArray alloc] init];
    //    variableNameArray = [[NSMutableArray alloc] init];
    timeStampArray = [[NSMutableArray alloc] init];
    
    //NSLog(@"outsideWrapper %@", outsideWrapper);
    
    for (FLmainmodel *mainModel in _outsideWrapper.value.timeSeries) {
        //if ([mainModel.variable.variableDescription isEqualToString:@"Discharge, cubic feet per second"]) {
        NSLog(@"location %@", mainModel.sourceInfo.siteName);
        //[tableNameArray addObject:mainModel.sourceInfo.siteName];
        NSArray *valueHolder = mainModel.values;
        for (ValuesModel *tempHolderDictionary in valueHolder) {
            //NSString *finalValue = [tempHolderDictionary objectForKey:@"value"];
            NSArray *finalValue = tempHolderDictionary.value;
            tempdetail = tempHolderDictionary.value;
        
            
        }
        
        for (ValueDetail *detailInstance in tempdetail) {
            
            if (arrayBool) {
                
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
                    innerArrayBool = NO;
                }else{
                    innerArrayBool = YES;
                }
                
                
                arrayBool = NO;
            }else{
                arrayBool = YES;
            }
            
            
            //[testDayArray addObject:testDay];
            
            
        }
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:filteredMonthArray];
        NSSet *uniqueDates = [orderedSet set];
        NSLog(@"uniqueDates %@", uniqueDates);
        finalMonthArray = [NSMutableArray arrayWithArray:[uniqueDates allObjects]];
    }
    
    
    NSLog(@"End of data");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"didLoadOne"
     object:nil];
    
}



@end
