//
//  MapViewController.m
//  RunnerTracker
//
//  Created by Xinjun on 23/10/13.
//  Copyright (c) 2013 Xinjun. All rights reserved.
//

#import "MapViewController.h"

#define INITIAL_SIZE_ARRAY 10
#define MIN_DEGREE_SPAN 0.000001

@implementation MyAnnotation

-(MyAnnotation *)initWithTitle:(NSString *)title subTitle:(NSString *) subTitle andCoordinate:(CLLocationCoordinate2D) location
{
    if (self = [super init]) {
        self.title = title;
        self.subtitle = subTitle;
        self.coordinate = location;
    }
    return self;
}

@end

typedef enum TrackingModeEnum{
    NotTrackingMode = 0,
    TrackingMode = 1,
    TrackingPause = 2,
}TrackingModeEnum;

@interface MapViewController ()
{
    CLLocationCoordinate2D *saveLocs;
    int corrdCount;
    int maxSize;
    double totalRunDist;
    NSArray *arrRoutePoints;
    BOOL bIsStarted;
}
@property (strong, nonatomic) CLLocationManager *locMgr;
@property (nonatomic) TrackingModeEnum tracingStatus;
@property (strong, nonatomic) MyAnnotation *startAnn, *endAnn;
@property BOOL m_FirstRun;

-(void) testDrawRouteFrom:(CLLocationCoordinate2D) startLoc;
+(BOOL) IsLocDiff:(CLLocationCoordinate2D) loc1 OtherLoc:(CLLocationCoordinate2D) loc2;
-(void) addCoordinate:(CLLocationCoordinate2D) newLoc;
@end

@implementation MapViewController

-(TrackingModeEnum)tracingStatus
{
    NSNumber *iStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"TracingStatus"];
    return [iStatus intValue];
}


-(void)setTracingStatus:(TrackingModeEnum)tracingStatus
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tracingStatus] forKey:@"TracingStatus"];
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
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopRecording)];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.locMgr = [[CLLocationManager alloc] init];
    [self.locMgr startUpdatingLocation];
    self.locMgr.delegate = self;
    self.mapView.delegate = self;
    self.title = @"Map View";
    self.m_FirstRun = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.mapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+(BOOL) IsLocDiff:(CLLocationCoordinate2D) loc1 OtherLoc:(CLLocationCoordinate2D) loc2
{
    if(fabs(loc1.latitude - loc2.latitude) > MIN_DEGREE_SPAN || fabs(loc1.longitude - loc2.longitude) > MIN_DEGREE_SPAN)
        return TRUE;
    
    return FALSE;
}

-(void) addCoordinate:(CLLocationCoordinate2D) newLoc
{
    if(!saveLocs)
    {
        saveLocs = malloc(INITIAL_SIZE_ARRAY * sizeof(CLLocationCoordinate2D));
        maxSize = INITIAL_SIZE_ARRAY;
    }
    
    if(corrdCount + 1 >= maxSize)
    {
        saveLocs = realloc(saveLocs, 2*maxSize*sizeof(CLLocationCoordinate2D));
        maxSize *= 2;
    }
    
    if (saveLocs) {
        saveLocs[corrdCount] = newLoc;
        corrdCount++;
        
        [self showLocalNotification:[NSString stringWithFormat:@"new location lat:%f long:%f", newLoc.latitude, newLoc.longitude]];
    }
}

- (void) showLocalNotification:(NSString *) strNotif
{
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = strNotif;
    localNotification.alertAction = @"Show detail";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
	// Schedule it with the app
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}


- (void) clickRecording
{
    /*if(bIsStarted)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startRecording)];
    }
    else
    {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopRecording)];

    }
    bIsStarted = !bIsStarted;*/
}


- (void) clickStartRecording
{
   
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(self.tracingStatus == NotTrackingMode || self.tracingStatus == TrackingPause)
        return;
    
//    if(self.m_FirstRun)
//    {
//        CLLocation *loc = [locations lastObject];
//        /*if (loc.horizontalAccuracy > 50.0) { //ignore the low accuracy position during startup
//            return;
//        }*/
//        
//        [self.mapView setRegion:MKCoordinateRegionMake(loc.coordinate, MKCoordinateSpanMake(0.001, 0.001)) animated:YES];
//        self.startAnn = [[MyAnnotation alloc] init];
//        self.startAnn.coordinate = loc.coordinate;
//        self.startAnn.title = @"Steve";
//        self.startAnn.subtitle = @"Start from here";
//        [self.mapView addAnnotation:self.startAnn];
//        [self.mapView selectAnnotation:self.startAnn animated:YES];
//        //[self testDrawRouteFrom:myPosition.coordinate];
//        //[self clickStartRecording];
//        self.m_FirstRun = FALSE;
//    }
    
    CLLocation *newLoc = [locations lastObject];
    if(newLoc && [MapViewController IsLocDiff:self.lastLoc OtherLoc:newLoc.coordinate])
    {
        if (self.lastLoc.latitude != 0.0 && self.lastLoc.longitude != 0.0)
        {
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.lastLoc.latitude longitude:self.lastLoc.longitude];
            double distance = [loc distanceFromLocation:newLoc];
            totalRunDist += distance;
            //self.title = [NSString stringWithFormat:@"%.1fm", totalRunDist];
            
            //arrRoutePoints = [self getRoutePointFrom:self.lastLoc to:newLoc.coordinate];
            //[self drawRoute];
            //[self centerMap];
        }
        
        self.lastLoc = newLoc.coordinate;
        [self addCoordinate:newLoc.coordinate];
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:saveLocs count:corrdCount];
        [self.mapView  addOverlay:self.objPolyline];
        
    }
    
}


//Following is the MKMapViewDelegate Method, which draws overlay. (iOS 4.0 and later)

/* MKMapViewDelegate Meth0d -- for viewForOverlay*/
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:self.objPolyline];
    view.fillColor = [UIColor blueColor];
    view.strokeColor = [UIColor blueColor];
    view.lineWidth = 10;
    return view;
}

-(void) testDrawRouteFrom:(CLLocationCoordinate2D) startLoc
{
    [self addCoordinate:startLoc];
    /*[self addCoordinate:CLLocationCoordinate2DMake(startLoc.latitude+2*MIN_DEGREE_SPAN, startLoc.longitude+2*MIN_DEGREE_SPAN)];
    [self addCoordinate:CLLocationCoordinate2DMake(startLoc.latitude+3*MIN_DEGREE_SPAN, startLoc.longitude+3*MIN_DEGREE_SPAN)];
    [self addCoordinate:CLLocationCoordinate2DMake(startLoc.latitude+4*MIN_DEGREE_SPAN, startLoc.longitude+4*MIN_DEGREE_SPAN)];
    [self addCoordinate:CLLocationCoordinate2DMake(startLoc.latitude+5*MIN_DEGREE_SPAN, startLoc.longitude+5*MIN_DEGREE_SPAN)];*/
    [self addCoordinate:CLLocationCoordinate2DMake(startLoc.latitude+6*MIN_DEGREE_SPAN, startLoc.longitude+6*MIN_DEGREE_SPAN)];
    self.objPolyline = [MKPolyline polylineWithCoordinates:saveLocs count:corrdCount];
    [self.mapView  addOverlay:self.objPolyline];
    
    [self.mapView setNeedsDisplay];
}


//The following function will get both the locations and prepare URL to get all the route points. And of course, will call stringWithURL.

/* This will get the route coordinates from the google api. */
- (NSArray*)getRoutePointFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    //NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}
//The following code is the real magic (decoder for the response we got from api). I would not modify that code unless I know what i am doing :)

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        printf("\n[%f,", [latitude doubleValue]);
        printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

//This function will draw route and will add overlay.

- (void)drawRoute
{
    int numPoints = [arrRoutePoints count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [arrRoutePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [self.mapView addOverlay:self.objPolyline];
        [self.mapView setNeedsDisplay];
    }
}
//The following code will center align the map.
- (void)centerMap
{
    MKCoordinateRegion region;
    
    static CLLocationDegrees maxLat = -90;
    static CLLocationDegrees maxLon = -180;
    static CLLocationDegrees minLat = 90;
    static CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < arrRoutePoints.count; idx++)
    {
        CLLocation* currentLocation = [arrRoutePoints objectAtIndex:idx];
        
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [self.mapView setRegion:region animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

-(void) startRecording
{
    
}


-(void) stopRecording
{
    if(self.endAnn)
    {
        [self.mapView removeAnnotation:self.endAnn];
    }
    self.endAnn = [[MyAnnotation alloc] init];
    self.endAnn.coordinate = self.lastLoc;
    self.endAnn.title = @"Total Distance";
    self.endAnn.subtitle = [NSString stringWithFormat:@"%.1f m", totalRunDist];
    [self.mapView addAnnotation:self.endAnn];
    [self.mapView selectAnnotation:self.endAnn animated:YES];
    
}


@end
