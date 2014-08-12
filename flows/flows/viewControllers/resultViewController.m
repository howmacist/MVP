//
//  resultViewController.m
//  flows
//
//  Created by Matt Riddoch on 7/26/14.
//  Copyright (c) 2014 Matt's in-house apps. All rights reserved.
//

#import "resultViewController.h"
#import "BEMSimpleLineGraphView.h"
#import "UIViewController+JASidePanel.h"
#import "mySidePanelViewController.h"
#import "JSONModelLib.h"
#import "FLoutsideWrapper.h"
#import "FLmainmodel.h"
#import "FLminMaxFlows.h"

@interface resultViewController () <BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSString *locationHolder;
@property (nonatomic, retain) BEMSimpleLineGraphView *meanView;
@property (nonatomic, retain) BEMSimpleLineGraphView *twentyFiveView;
@property (nonatomic, retain) BEMSimpleLineGraphView *seventyFiveView;
@property (nonatomic, retain) BEMSimpleLineGraphView *dataView;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation resultViewController{
    int previousStepperValue;
    
    NSMutableArray *colorHolder;
    NSMutableArray *colorHolderTwo;
    BEMSimpleLineGraphView *mainView;
    //BEMSimpleLineGraphView *mainViewTwo;
    
    
    NSMutableArray *holderTest;
    
    NSMutableArray *finalValues;
    
    
    //new arrays
    //NSMutableArray *meanArray;
    NSMutableArray *twentyFiveArray;
    NSMutableArray *seventyFiveArray;
    
    NSMutableArray *pickerOneArray;
    //RMPickerViewController *pickerVC;
    
    NSMutableArray *timeStampArray;
    FLoutsideWrapper* _outsideWrapper;
    NSArray<ValueDetail>* tempdetail;
    
    NSMutableArray *filteredMonthArray;
    NSMutableArray *finalMonthArray;
    
    NSNumber* minForGraphs;
    NSNumber* maxForGraphs;
    //NSNumber* meanForGraphs;
    
    //NSString *locationHolder;
    
    NSURL *flowData;
    NSURL *finalData;
    
    BOOL arrayBool;
    BOOL innerArrayBool;
    
    NSString *stringForGraphs;
    
    NSString *resultHolder;
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
    
    holderTest = [[NSMutableArray alloc] init];
    
    colorHolder = [[NSMutableArray alloc] init];
    colorHolderTwo = [[NSMutableArray alloc] init];
    
    twentyFiveArray = [[NSMutableArray alloc] init];
    seventyFiveArray = [[NSMutableArray alloc] init];
    
    finalValues = [[NSMutableArray alloc] init];
    timeStampArray = [[NSMutableArray alloc] init];
    
    filteredMonthArray = [[NSMutableArray alloc] init];
    finalMonthArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"TestNotification"])
        NSLog (@"Successfully received the test notification!");
    NSDictionary *incomingInfo = notification.userInfo;
    //_outsideWrapper = [incomingInfo objectForKey:@"wrapperToPass"];
    //stringForGraphs = [incomingInfo objectForKey:@"resultForGraphString"];
    //NSLog(@"stringForGraphs %@", stringForGraphs);
    //[self fireUpGraphs];
    _titleLabel.text = [incomingInfo objectForKey:@"titleToPass"];
    _locationLabel.text = [incomingInfo objectForKey:@"locationToPass"];
    
    twentyFiveArray = [incomingInfo objectForKey:@"twentyFiveValues"];
    seventyFiveArray = [incomingInfo objectForKey:@"seventyFiveValues"];
    finalValues = [incomingInfo objectForKey:@"finalValues"];
    //timeStampArray = [incomingInfo objectForKey:@"finalTimeStamp"];
    
    
    [self setUpGraphs];
    
}




- (void)setUpGraphs{
    

    
    //    float twentyFiveMin = [twentyFiveArray valueForKeyPath:@"@min.self"];
    //    float seventyFiveMax = [seventyFiveArray valueForKeyPath:@"@max.self"];
    //    //NSNumber* finalMin = [finalValues valueForKeyPath:@"@min.self"];
    //    float finalMin = (int)[finalValues valueForKeyPath:@"@min.self"];
    //    //NSNumber* finalMax = [finalValues valueForKeyPath:@"@max.self"];
    //    float finalMax = (int)[finalValues valueForKeyPath:@"@max.self"];
    
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
    
    //tempMeanHolder = tempMaxHolder - tempMinHolder;
    //meanForGraphs = [NSNumber numberWithFloat:tempMeanHolder / 2];
    
    NSLog(@"test");
    
    [self populateMeanGraph];
    
}


- (void)populateMeanGraph{
//    meanView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
//    meanView.delegate = self;
//    
//    
//    meanView.enableTouchReport = NO;
//    
//    meanView.minValue = [minForGraphs floatValue];
//    meanView.maxValue = [maxForGraphs floatValue];
//    meanView.enableBezierCurve = NO;
//    meanView.colorBottom = [UIColor clearColor];
//    meanView.colorTop = [UIColor clearColor];
//    meanView.colorLine = [UIColor colorWithRed:111/255.0f green:229/255.0f blue:125/255.0f alpha:1.0f];
//    meanView.widthLine = 1;
//    meanView.animationGraphEntranceSpeed = 0;
    
    
    //_twentyFiveView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    _twentyFiveView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(10, 150, 300, 400)];
    _twentyFiveView.delegate = self;
    
    
    _twentyFiveView.enableTouchReport = NO;
    
    _twentyFiveView.minValue = [minForGraphs floatValue];
    _twentyFiveView.maxValue = [maxForGraphs floatValue];
    _twentyFiveView.enableBezierCurve = NO;
    _twentyFiveView.colorBottom = [UIColor clearColor];
    _twentyFiveView.colorTop = [UIColor clearColor];
    _twentyFiveView.colorLine = [UIColor colorWithRed:6/255.0f green:119/255.0f blue:236/255.0f alpha:1.0f];
    _twentyFiveView.widthLine = 1;
    _twentyFiveView.animationGraphEntranceSpeed = 0;
    
    
    
    //_seventyFiveView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    _seventyFiveView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(10, 150, 300, 400)];
    _seventyFiveView.delegate = self;
    
    
    _seventyFiveView.enableTouchReport = NO;
    
    _seventyFiveView.minValue = [minForGraphs floatValue];
    _seventyFiveView.maxValue = [maxForGraphs floatValue];
    _seventyFiveView.enableBezierCurve = NO;
    _seventyFiveView.colorBottom = [UIColor clearColor];
    _seventyFiveView.colorTop = [UIColor clearColor];
    _seventyFiveView.colorLine = [UIColor colorWithRed:234/255.0f green:105/255.0f blue:71/255.0f alpha:1.0f];
    _seventyFiveView.widthLine = 1;
    _seventyFiveView.animationGraphEntranceSpeed = 0;
    
    
    //[self.view addSubview:meanView];
    [self.view addSubview:_twentyFiveView];
    [self.view addSubview:_seventyFiveView];
}

- (void)populateTheDataGraph{
    //_dataView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    _dataView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(5, 150, 300, 400)];
    _dataView.delegate = self;
    
    
    _dataView.enableTouchReport = YES;
    
    //dataView.minValue = 2;
    //dataView.maxValue = 10;
    _dataView.enableBezierCurve = YES;
    //dataView.colorBottom = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
    _dataView.colorBottom = [UIColor clearColor];
    _dataView.colorTop = [UIColor clearColor];
    _dataView.colorLine = [UIColor whiteColor];
    _dataView.widthLine = 3;
    _dataView.animationGraphEntranceSpeed = 0;
    
    _dataView.minValue = [minForGraphs floatValue];
    _dataView.maxValue = [maxForGraphs floatValue];
    
    [self.view addSubview:_dataView];
 
#pragma mark - TODO labels
    
    //maxLabel.text = [maxForGraphs stringValue];
    //meanLabel.text = [meanForGraphs stringValue];
    //minLabel.text = [minForGraphs stringValue];
    
    [self.dataView reloadGraph];
}


#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    //if (graph == meanView) {
    //    return (int)[meanArray count];
    if (graph == _twentyFiveView){
        return (int)[twentyFiveArray count];
    }else if (graph == _seventyFiveView){
        return (int)[seventyFiveArray count];
    }else if (graph == _dataView){
        return (int)[finalValues count];
    }
    
    return 0;
    
    //return  holderTest.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    //if (graph == meanView) {
    //    return [[meanArray objectAtIndex:index] floatValue];
    if (graph == _twentyFiveView){
        return [[twentyFiveArray objectAtIndex:index] floatValue];
    }else if (graph == _seventyFiveView){
        return [[seventyFiveArray objectAtIndex:index] floatValue];
    }else if (graph == _dataView){
        return [[finalValues objectAtIndex:index] floatValue];
    }
    return 0;
    //    NSLog(@"holderValue %f", [[holderTest objectAtIndex:index] floatValue]);
    //    return [[holderTest objectAtIndex:index] floatValue];
    //    NSLog(@"test");
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    //    if (graph == mainView) {
    //        return ArrayOfDates[index];
    //    }else if (graph == mainViewTwo){
    //        return @"";
    //    }
    return @"";
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 100; // The number of hidden labels between each displayed label.
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    // Here you could change the text of a UILabel with the value of the closest index for example.
    //valueLabel.text = ArrayOfValues[index];
    //valueLabel.text = [NSString stringWithFormat:@"%ld",(long)ArrayOfValues[index]];
#pragma mark - TODO label text
    _resultLabel.text = [NSString stringWithFormat:@"%@",finalValues[index]];
    //resultHolder = [NSString stringWithFormat:@"%@",finalValues[index]];
    //dateStampLabel.text = [NSString stringWithFormat:@"%@", timeStampArray[index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    // Set the UIlabel alpha to 0 for example.
    //valueLabel.text = @"0";
    _resultLabel.text = [NSString stringWithFormat:@"%@", [finalValues lastObject]];
    
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph{
    
    //    UIImage *meanone = [[UIImage alloc] init];
    //    if (graph == meanView) {
    //        meanone = [self.meanView graphSnapshotImage];
    //    }
    
    //UIImage *twenty = [twentyFiveView graphSnapshotImage];
    //UIImage *seventy = [seventyFiveView graphSnapshotImage];
    
    //    UIImageView *imageHolder = [[UIImageView alloc] initWithImage:meanone];
    //    imageHolder.frame = CGRectMake(0, 370, 320, 320);
    //    [self.view addSubview:imageHolder];
    
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    //
    //    // Save image.
    //    [UIImagePNGRepresentation(meanone) writeToFile:filePath atomically:YES];
    if (graph == _seventyFiveView) {
        //[testImage setImage:meanone];
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self screenshot];
        });
        
        
    }
    
    
}

- (UIImage *) screenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    
    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    [_testImage setImage:image];
    self.meanView = nil;
    self.twentyFiveView = nil;
    self.seventyFiveView = nil;
    
    for (UIView *subView in self.view.subviews){
        if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    //[self.meanView removeFromSuperview];
    //[self.twentyFiveView removeFromSuperview];
    //[self.seventyFiveView removeFromSuperview];
    
    _resultLabel.text = [NSString stringWithFormat:@"%@", [finalValues lastObject]];
    
    [self populateTheDataGraph];
    
    
    
    
    //    dispatch_async(kBgQueue, ^{
    //        NSData* data = [NSData dataWithContentsOfURL:
    //                        riverFinalData];
    //        [self performSelectorOnMainThread:@selector(fetchedFinalData:)
    //                               withObject:data waitUntilDone:YES];
    //    });
    
    
    return image;
    
}

#pragma mark - IBActions



- (IBAction)closeClicked:(id)sender {
    
    [self.sidePanelController showCenterPanelAnimated:YES];
    [_testImage setImage:nil];
    //meanView = nil;
    //self.meanView = nil;
    //self.twentyFiveView = nil;
    //self.seventyFiveView = nil;
    self.dataView = nil;
    for (UIView *subView in self.view.subviews){
        if ([subView isKindOfClass:[BEMSimpleLineGraphView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [_resultLabel setText:@""];
//    [maxLabel setText:@""];
//    [meanLabel setText:@""];
//    [minLabel setText:@""];
//    [valueLabel setText:@""];
//    [dateStampLabel setText:@""];
    
    holderTest = [[NSMutableArray alloc] init];
    
    colorHolder = [[NSMutableArray alloc] init];
    colorHolderTwo = [[NSMutableArray alloc] init];
    
    
    
    //meanArray = [[NSMutableArray alloc] init];
    twentyFiveArray = [[NSMutableArray alloc] init];
    seventyFiveArray = [[NSMutableArray alloc] init];
    
    finalValues = [[NSMutableArray alloc] init];
    
    filteredMonthArray = [[NSMutableArray alloc] init];
    finalMonthArray = [[NSMutableArray alloc] init];
    
}


@end
